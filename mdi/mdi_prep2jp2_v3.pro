;
; 10 April 2009
;
; 2009/04/10 - JI, first version with direct FITS to JP2 conversion
;
; Take a list of MDI images, prep them, and turn them
; into a set of jp2 files with XML headers corresponding to
; the original FITS header
;
; -
; The original files are read in, prepped,
; and dumped as a JP2 file
;
;
; USER - set the variable "mdidir" to the root directory of where the
;        MDI FITS data is.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
mdidir = '~/hv/dat/mdi/2003/'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'mdi_prep2jp2_v3'
nickname = 'MDI'
;
; Storage locations
;
storage = JI_HV_STORAGE()
;
; MDI Intensity
; Start timing
;
t0 = systime(1)
list = file_search(mdidir,'*Ic*.00*.fits')

;
; The filename for a file which will contain the locations of the
; JP2 log files
;
filename = JI_HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Write direct to JP2 from FITS
;
prepped = JI_MDI_WRITE_HVS(storage.hvs_location,filename,storage.jp2_location,/int)
; 
; Save the log file
;
JI_HV_LOG_WRITE,subdir,filename,prepped,/verbose
;
; Report time taken
;
JI_HV_REPORT_WRITE_TIME,progname,t0,prepped
;
; ======================================================================================================
;
; MDI Magnetogram
;
t0 = systime(1)
list = file_search(mdidir,'*M*.00*.fits')

;
; The filename for a file which will contain the locations of the
; JP2 log files
;
filename = JI_HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Write direct to JP2 from FITS
;
prepped = JI_MDI_WRITE_HVS(storage.hvs_location,filename,storage.jp2_location,/mag)
; 
; Save the log file
;
JI_HV_LOG_WRITE,subdir,filename,prepped,/verbose
;
; Report time taken
;
JI_HV_REPORT_WRITE_TIME,progname,t0,prepped
;
;
;
end
