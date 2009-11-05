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
progname = 'eit_prep2jp2_auto1' ; the program name
nickname = 'EIT' ; instrument nickname
;
; Get the observer details
;
oidm = JI_HV_OIDM2(nickname)
;
; Storage locations
;
storage = JI_HV_STORAGE()
;
; Create the log subdirectory for this nickname
;
JI_HV_LOG_CREATE_SUBDIRECTORY,storage.log_location,nickname,subdir = subdir
;
; Infinite loop
;
repeat begin
;
; Look in the log directory to get the last run data: look for log files from the instrument 'nickname'
;
   date_most_recent = (JI_HV_LOG_CHECK_PROCESSED(storage.log_location,nickname)).date_most_recent
   if (date_most_recent eq -1) then begin
      get_utc,utc,/ecs,/date_only
      date_most_recent = utc
   endif
;
; Get today's date in UT
;
   get_utc,utc,/ecs,/date_only
   date_start = date_most_recent
   date_end   = utc
   print,' '
   print,progname + ': Processing... ' + date_start + ' to ' + date_end
;
; Create the subdirectory for the log file.  First we create an hvs
;
   JI_HV_LOG_CREATE_SUBDIRECTORY,storage.log_location,nickname,date = strmid(utc,0,4) + strmid(utc,5,2) + strmid(utc,8,2),subdir = subdir
;
; ===================================================================================================
;
; Start timing
;
   s0 = systime(1)
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
   filename = nickname + '__' + strmid(date_start,0,4) + strmid(date_start,5,2) + strmid(date_start,8,2) + '-' + $
              strmid(date_end,0,4) + strmid(date_end,5,2) + strmid(date_end,8,2) + '.txt'
;
; Create the location of the listname
;
   listname = subdir + filename + '.prepped.log'
;
; Write direct to JP2 from FITS
;
   prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
   s1 = systime(1)
   s1_time = systime(0)
;
; Save the log file
;
   JI_HV_LOG_WRITE,listname,prepped,/verbose 
;
; Move the data one day at a time
;
   n1 = n_elements(prepped)
   s2 = systime(1)
   date_start_dmy = nint(strsplit(date_start,'/',/extract))
   date_end_dmy = nint(strsplit(date_end,'/',/extract))
   current_date = date2mjd(date_start_dmy[0],date_start_dmy[1],date_start_dmy[2])
   while current_date le date2mjd(date_end_dmy[0],date_end_dmy[1],date_end_dmy[2]) do begin
      mjd2date,current_date,yy,mm,dd
      yy = trim(yy)
      if mm le 9 then begin
         mm = '0' + trim(mm)
      endif else begin
         mm = trim(mm)
      endelse
      if dd le 9 then begin
         dd = '0' + trim(dd)
      endif else begin
         dd = trim(dd)
      endelse
      hvs = {observatory:oidm.observatory,$
             instrument:oidm.instrument,$
             detector:oidm.detector,$
             measurement:'',$
             yy:yy, mm:mm, dd:dd}
      source = JI_HV_WRITE_LIST_JP2_MKDIR(hvs,storage.jp2_location)
;      JI_HV_JP2_MOVE_SCRIPT,nickname, source, '/Users/ireland/hv/incoming',hvs
      current_date = current_date + 1
   endwhile
   s3 = systime(1)
;
; Timing stats
;
   print,' '
   print,progname + ': most recent file processed = '+prepped[n_elements(prepped)-1]   
   print,'Total number of files ',n1
   print,'Total time taken ',s1-s0
   print,'Average time taken ',(s1-s0)/float(n1)
   print,'Last JP2 written at ',s1_time
   print,'File transfer completed at ',systime(0)
   print,'File transfer time ',s3-s2
;
; Wait 15 minutes before looking for more data
;
   print,'Fixed wait time of 1 hour now progressing.'
   wait,60*60

endrep until 1 eq 0

end
