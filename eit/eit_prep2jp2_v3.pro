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
date_start = '2009/10/08'
date_end   = '2009/10/09'

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
; Create the subdirectory for the log file.  First we create an hvs
;
   JI_HV_LOG_CREATE_SUBDIRECTORY,storage.log_location,nickname,date = strmid(date_start,0,4) + strmid(date_start,5,2) + strmid(date_start,8,2),subdir = subdir
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
; Write direct to JP2 from FITS
;
prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
; 
; Save the log file
;
JI_HV_LOG_WRITE,subdir,filename + '.prepped.log',prepped,/verbose
;
; Report time taken
;
n1 = n_elements(prepped)
s1 = systime(1)
print,'Total number of files ',n1
print,'Total time taken ',s1-s0
print,'Average time taken ',(s1-s0)/float(n1)

;JI_HV_JP2_MOVE_DAYS,'EIT',date_start,date_end

end
