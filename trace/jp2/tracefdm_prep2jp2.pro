;
; Prep a set of TRACE FDMs between a given time range
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
progname = 'trace_prep2jp2'
;
; Call details of storage locations
;
storage = JI_HV_STORAGE()

;
; A file containing the absolute locations of the
; TRACEFDMs files to be processed
;
list = ???-list generated somehow-???
filename = progname + '_' + ji_txtrep(ji_systime(),':','_') + 'int.sav'
save,filename = storage.hvs_location + filename, list

;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.prepped.txt'

;
; ===================================================================================================
;
;
; Write direct to JP2 from FITS
;
prepped = JI_TRACEFDM_WRITE_HVS(date_start,$
                           date_end,  $
                           storage.jp2_location,$
                           write = write)
;
; Files that have been prepped
;
save,filename = listname,prepped




end
