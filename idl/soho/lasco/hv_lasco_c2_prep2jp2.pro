;
; 7 April 09
;
; lasco_c2_prep2jp2_v2.pro
;
; Take a list of LASCO C2 files and
; (1) prep the data
; (2) write out jp2 files
;
;
; USER - use the LASCO software program (in Solarsoft) to determine
;        the time range you are interested in.  The program will then
;        create JP2 files in the correct directory structure for use
;        with the Helioviewer project.

PRO HV_LASCO_C2_PREP2JP2,ds,de,details_file = details_file,called_by = called_by, copy2outgoing = copy2outgoing,alternate_backgrounds = alternate_backgrounds,prepped = prepped,report=report
  progname = 'HV_LASCO_C2_PREP2JP2'
;
  date_start = ds + 'T00:00:00'
  date_end = de + 'T23:59:59'
;
; ===================================================================================================
;
; use the default LASCO-C2 HVS file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_lasco_c2'
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname
;
; if using the alternate backgrounds, got to the web and get the
; latest from NRL.
;
  IF keyword_set(alternate_backgrounds) then begin
     hv_lasco_update_alternate_backgrounds,details_file = details_file
     progname = progname + '(used alternate backgrounds from ' + alternate_backgrounds + ')'
     setenv,'MONTHLY_IMAGES=' + alternate_backgrounds
  endif
;
;
; get general information
;
  ginfo = CALL_FUNCTION('hvs_gen')
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
  list = HV_LASCO_GET_FILENAMES(date_start,date_end,nickname,info)
  if (list[0] eq ginfo.MinusOneString) then begin
     report = ['No files to process']
     print,report[0]
     prepped = strarr(1)
     prepped[0] = ginfo.MinusOneString
  endif else begin
;
; Setup some defaults - usually there is NO user contribution below here
;
; Start a clock
;
     t0 = systime(1)
;
; Call details of storage locations
;
     storage = HV_STORAGE(nickname = nickname)
;
; Write direct to JP2 from FITS
;
     prev = fltarr(1024,1024)
     output = HV_LAS_WRITE_HVS3(list,storage.jp2_location,nickname,date_start,date_end,/bf_process,details = info)
     prepped = output.hv_count
     nawind = where(prepped eq ginfo.already_written,naw)
     nm1ind = where(prepped eq ginfo.MinusOneString,nm1)
     nnew = n_elements(prepped) - naw - nm1
;
; Report time taken
;
     HV_REPORT_WRITE_TIME,progname,t0,nnew,report=report
;
; Copy2outgoing
;
     if keyword_set(copy2outgoing) then begin
        HV_COPY2OUTGOING,prepped
     endif
  endelse


  return
end
