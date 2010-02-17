;
; Prep a set of EIT images between a given time range (ds -> de)
;
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
; USER - set the start date and end date of the range of EIT data you
;        are interested in.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
PRO HV_EIT_PREP2JP2,ds,de,auto = auto,details_file = details_file
  progname = 'hv_eit_prep2jp2'
;
; use the default EIT file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_eit'
;
  details = CALL_FUNCTION(details_file)
;
; Go through the requested dates
;
  if not(keyword_set(auto)) then begin
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
     storage = HV_STORAGE(nickname = details.nickname)
;
; Start timing
;
     t0 = systime(1)
;
; Write direct to JP2 from FITS
;
     prepped = HV_EIT_WRITE(date_start,date_end,storage.jp2_location,details)
;
; Report time taken
;
     HV_REPORT_WRITE_TIME,progname,t0,prepped
  endif else begin
     HV_EIT_PREP2JP2_AUTO,ds,de
  endelse


  return
end
