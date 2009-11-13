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
nickname = 'EIT'
date_start = '2009/09/21' + 'T00:00:00.000'
date_end   = '2009/09/21' + 'T23:59:59.000'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'eit_prep2jp2_v3'
;
; Storage locations
;
storage = JI_HV_STORAGE(nickname = nickname)
;
; Start timing
;
t0 = systime(1)
;
; Write direct to JP2 from FITS
;
prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
;
; Report time taken
;
JI_HV_REPORT_WRITE_TIME,progname,t0,prepped


end
