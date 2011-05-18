;
; 22 April 2010
;
; Version 1 of conversion of SDO data to JP2
; Based on the AIA data analysis guide.
;
; Initial version only - will probably need significant edits
;
PRO hv_aia_prep2jp2,date_start = date_start,$
                    date_end = date_end,$
                    details_file = details_file,$
                    wavelnth = wavelnth,$
                    copy2outgoing = copy2outgoing,$
                    called_by = called_by,$
                    level = level
;
; start time
;
  t0 = systime(1)
;
; program name
;
  progname = 'hv_aia_prep2jp2'

  if (anytim2tai(date_start) gt anytim2tai(date_end)) then begin
     print,progname + ': start time after end time.  Check times passed to routine.  Stopping.'
     stop
  endif

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
; Get the list of files
;
  if not(keyword_set(waves)) then begin
     wavelnth = info.measurement[0]
  endif
  if not(keyword_set(level)) then begin
     level = 1.5
  endif
  aia = sdo_time2files(date_start,date_end,level=level,/aia,waves=wavelnth)
  mreadfits_shm,aia,index
  ss=struct_where(index,search=['wavelnth=' + wavelnth,'img_type=LIGHT']) 
  nss = n_elements(ss,ncount)
  if ncount eq 0 then begin
     report = ['No files to process']
     print,report[0]
     prepped = strarr(1)
     prepped[0] = g.MinusOneString
  endif else begin
;
; Get the fitsnames
;
     prepped = strarr(nss)
     for i = 0,nss-1 do begin
        fullname = aia[ss[i]] ; get the full directory and filename
        z = strsplit(fullname,path_sep(),/extract) ; split up to get filename
        nz = n_elements(z)
        fitsname = z[nz-1]
        mreadfits_shm,fullname,index,img ; read the individual filename
        HV_AIA_D2JP2,fitsname,img,header,$
                     jp2_filename = jp2_filename, $
                     already_written = already_written
        prepped[i] = jp2_filename
     endfor
  endelse
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
