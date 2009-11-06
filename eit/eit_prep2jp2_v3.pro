;
; Prep a set of EIT images between a given time range
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
date_start = '1999/01/01' + 'T00:00:00.000'
date_end   = '1999/12/31' + 'T23:59:59.000'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'eit_prep2jp2_v3'
nickname = 'EIT' ; instrument nickname
;
; Storage locations
;
storage = JI_HV_STORAGE()
;
; Create the subdirectory for the log file.
;
JI_HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
;
; Start timing
;
t0 = systime(1)
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
filename = JI_HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Write direct to JP2 from FITS
;
prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
; 
; Save the log file
;
JI_HV_LOG_WRITE,subdir,filename,prepped,/verbose
;
; Report time taken
;
JI_HV_REPORT_WRITE_TIME,progname,t0,prepped


end
