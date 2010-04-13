;
; Prep a set of EIT images between a given time range (ds -> de)
;
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
; sudo mount 129.165.40.191:/Volumes/eit /home/ireland/soho/eit
;
; USER - set the start date and end date of the range of EIT data you
;        are interested in.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
PRO HV_EIT_PREP2JP2,ds,de,details_file = details_file, copy2outgoing = copy2outgoing,output = output,called_by = called_by, prepped = prepped,report = report
;
; Program name
;
  progname = 'hv_eit_prep2jp2'
;
; use the default EIT file if no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_eit'
  info = CALL_FUNCTION(details_file)
;
; Get general JP2Gen information
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
; Fix the dates if need be
;
  if de eq -1 then begin
     get_utc,de,/ecs,/date_only
     print,progname,': end date reset to ' + de
  endif
  if ds eq -1 then begin
     get_utc,ds,/ecs,/date_only
     print,progname,': start date reset to ' + ds
  endif
  if anytim2tai(ds) gt anytim2tai(de) then begin
     print,progname,': start time before end time.  Stopping'
     stop
  endif
  
  date_start = ds + 'T00:00:00.000'
  date_end   = de + 'T23:59:59.000'
;
; Storage locations
;
  storage = HV_STORAGE(nickname = info.nickname)
;
; Start timing
;
  t0 = systime(1)
;
; Write direct to JP2 from FITS
;
  output = HV_EIT_WRITE(date_start,date_end,storage.jp2_location,info)
  prepped = output.hv_count
  nawind = where(prepped eq ginfo.already_written,naw)
  nnew = n_elements(prepped)- naw
;
; Report time taken
;
  HV_REPORT_WRITE_TIME,progname,t0,nnew,report = report
;
; Copy the new files to the outgoing directory
;
  if keyword_set(copy2outgoing) then begin
     HV_COPY2OUTGOING,prepped
  endif

  return
end
