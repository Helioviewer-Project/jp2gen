;
; 22 April 2010
;
; Version 1 of conversion of SDO data to JP2
; Based on the AIA data analysis guide.
;
; Initial version only - will probably need significant edits
;
PRO hv_aia_list2jp2,list,$
                    details_file = details_file,$ ; AIA details file
                    copy2outgoing = copy2outgoing,$ ; Copy the files to an outgoing directory
                    called_by = called_by,$ ; calling program (if any)
                    transfer_direct = transfer_direct ; transfer JP2 files from local to remote direct from original JP2 archive.
;
; start time
;
  t0 = systime(1)
;
; program name
;
  progname = 'hv_aia_list2jp2'

; use the default AIA file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_aia'
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname
;
; get general information
;
  g = HVS_GEN()
;
; If called_by information is given, pass it along.  Otherwise, just
; use this program name
;
  if keyword_set(called_by) then begin
     info = add_tag(info,called_by,'called_by')
  endif else begin
     info = add_tag(info,progname,'called_by')
  endelse
;
; All the supported measurements
;
  wave_arr = info.details[*].measurement
;
; Number of elements in the list
;
  nl = n_elements(list)
  prepped = strarr(nl)
;
; Get the fitsnames
;
  for i = 0,nl-1 do begin
     fullname = list[i]         ; get the full directory and filename
     z = strsplit(fullname,path_sep(),/extract) ; split up to get filename
     nz = n_elements(z)
     fitsname = z[nz-1]
     hd = fitshead2struct(headfits(fullname)) ; get the FITS header only
;
; Check that this FITS file is supported
;
     this_wave = where(wave_arr eq trim(hd.wavelnth),this_wave_count)
     if this_wave_count eq 0 then begin
        measurement = 'not_supported'
     endif else begin
        measurement = trim(hd.wavelnth)
     endelse
;
; Construct an HVS
;
     tobs = HV_PARSE_CCSDS(hd.date_obs)
     hvs = {dir:'',$
            fitsname:fitsname,$
            img:-1,$
            header:hd,$
            yy:tobs.yy,$
            mm:tobs.mm,$
            dd:tobs.dd,$
            hh:tobs.hh,$
            mmm:tobs.mmm,$
            ss:tobs.ss,$
            milli:tobs.milli,$
            measurement:measurement,$
            details:info}
;
; In the Data base already
;
     HV_DB,hvs,/check_fitsname_only,already_written = already_written
;
; Write it if it is NOT in the database
;
     if not(already_written) then begin
        img = readfits(fullname) ; read the individual filename
        HV_AIA_D2JP2,fitsname,img,hd,$
                     jp2_filename = jp2_filename, $
                     already_written = already_written
        prepped[i] = jp2_filename
     endif else begin
        print,progname + ': file already written = '+ fitsname
        prepped[i] = g.already_written
     endelse
  endfor
;
; Report time taken and number of files written
;
  nawind = where(prepped eq g.already_written,naw)
  nm1ind = where(prepped eq g.MinusOneString,nm1)
  nnew = n_elements(prepped) - naw - nm1
  HV_REPORT_WRITE_TIME,progname,t0,nnew,report=report
;
; Copy2outgoing
;
  if keyword_set(copy2outgoing) then begin
     HV_COPY2OUTGOING,prepped
  endif
;
; Transfer direct from local archive to local machine
;
  if keyword_set(transfer_direct) then begin
     HV_JP2_TRANSFER_DIRECT,prepped
  endif
  RETURN
END
