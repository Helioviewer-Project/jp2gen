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
;date_start = '1997/10/05'
;date_end   = '1997/10/05'
date_start = '2008/01/01'
date_end   = '2008/12/31'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'eit_prep2jp2_v3'
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()
;
; Start timing
;
s0 = systime(1)

;
; The filename for a file which will contain the locations of the
; JP2 log files
;
filename = ji_txtrep(date_start,'/','_') + '-' + ji_txtrep(date_end,'/','_') + '.txt'

;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.prepped.log'

;
; ===================================================================================================
;
;
; Write direct to JP2 from FITS
;
prepped = JI_EIT_WRITE_HVS(date_start,date_end,storage.jp2_location)
;
; 
;
save,filename = listname,prepped

n1 = n_elements(prepped)
s1 = systime(1)
print,'Total number of files ',n1
print,'Total time taken ',s1-s0
print,'Average time taken ',(s1-s0)/float(n1)

JI_HV_JP2_MOVE_DAYS,'EIT',date_start,date_end

end
