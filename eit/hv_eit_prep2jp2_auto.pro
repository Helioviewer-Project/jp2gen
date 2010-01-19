;
; 9 September 2009.
;
; Prep Quicklook EIT images for use with the Helioviewer Project
;
; Gets today's date (UTC) and looks for new EIT files once every 15 minutes.
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
;
PRO HV_EIT_PREP2JP2_AUTO,ds,de
  progname = 'ji_hv_eit_prep2jp2_auto' ; the program name
  nickname = 'EIT'                     ; instrument nickname
;
; If the start or end dates are -1, write the appropriate
; files
;
  if ((ds eq -1) or (de eq -1)) then begin
     HV_EIT_PREP2JP2,ds,de
  endif
;
; Get the observer details
;
  oidm = HV_OIDM2(nickname)
;
; Storage locations
;
  storage = HV_STORAGE(nickname = nickname)
;
; Create the log subdirectory for this nickname
;
  HV_LOG_CREATE_SUBDIRECTORY,nickname
;
; Infinite loop
;
  nwrite = long(0)
  repeat begin
;
; Look in the log directory to get the last run data: look for log files from the instrument 'nickname'
;
     date_most_recent = (HV_LOG_CHECK_PROCESSED(nickname)).most_recent
     if (date_most_recent eq -1) then begin
        get_utc,utc,/ecs,/date_only
        date_most_recent = utc
     endif else begin
        date_most_recent = strmid(date_most_recent,0,10) + 'T00:00:00.000'
     endelse
;
; Get today's date in UT
;
     date_start = date_most_recent
     get_utc,utc,/ecs,/date_only
     date_end   = utc + 'T23:59:59.000'
     print,' '
     print,progname + ': Processing... ' + date_start + ' to ' + date_end
;
; Create the subdirectory for the log file.  First we create an hvs
;
     HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
;
; ===================================================================================================
;
; Start timing
;
     t0 = systime(1)
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
     filename = HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Create the location of the listname
;
     listname = filename + '.prepped.log'
;
; Write direct to JP2 from FITS
;
     prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
     nwrite = nwrite + long(1)
     tMostRecent = systime(0)
;
; Save the log file
;
;   HV_LOG_WRITE,subdir,listname,prepped,/verbose
;
; Timing stats
;
     HV_REPORT_WRITE_TIME,progname,t0,prepped
     print,'Last file written at approximately ',tMostRecent
     print,'Number of successful FITS to JP2 preparation script executions since this program was launched ',nwrite
;
; Wait 15 minutes before looking for more data
;
     print,'Fixed wait time of 15 minutes now progressing.'
     wait,60*15.0

  endrep until 1 eq 0

  return
end

;   n1 = n_elements(prepped)
;   s2 = systime(1)
;   date_start_dmy = nint(strsplit(date_start,'/',/extract))
;   date_end_dmy = nint(strsplit(date_end,'/',/extract))
;   current_date = date2mjd(date_start_dmy[0],date_start_dmy[1],date_start_dmy[2])
;   while current_date le date2mjd(date_end_dmy[0],date_end_dmy[1],date_end_dmy[2]) do begin
;      mjd2date,current_date,yy,mm,dd
;      yy = trim(yy)
;      if mm le 9 then begin
;         mm = '0' + trim(mm)
;      endif else begin
;         mm = trim(mm)
;      endelse
;      if dd le 9 then begin
;         dd = '0' + trim(dd)
;      endif else begin
;         dd = trim(dd)
;      endelse
;      hvs = {observatory:oidm.observatory,$
;             instrument:oidm.instrument,$
;             detector:oidm.detector,$
;             measurement:'',$
;             yy:yy, mm:mm, dd:dd}
;      source = HV_WRITE_LIST_JP2_MKDIR(hvs,storage.jp2_location)
;      HV_JP2_MOVE_SCRIPT,nickname, source, '/Users/ireland/hv/incoming',hvs
;      current_date = current_date + 1
;   endwhile
;   s3 = systime(1)
