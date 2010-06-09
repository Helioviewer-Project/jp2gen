;
; 22 April 2010
;
; Version 1 of conversion of SDO data to JP2
; Based on the AIA data analysis guide.
;
; Initial version only - will probably need significant edits
;
PRO hv_aia_list2jp2,list,$
                    details_file = details_file,$
                    copy2outgoing = copy2outgoing,$
                    called_by = called_by
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
     img = readfits(fullname,header) ; read the individual filename
     HV_AIA_D2JP2,fitsname,img,header,$
                  jp2_filename = jp2_filename, $
                  already_written = already_written
     plot_image,img,title = header.wavelnth
     prepped[i] = jp2_filename
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

  RETURN
END
