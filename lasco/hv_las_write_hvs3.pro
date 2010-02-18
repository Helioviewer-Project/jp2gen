;
; Take a list of LASCO files and write them out as JP2s
;
; dir = directory where the file list is
; filename = the filename containing the list of files
; rootdir = the root directory where the JP2 files are stored
;
; c1 = choose LASCO c1
; c2 = choose LASCO c2
; c3 = choose LASCO c3
;
;
;
FUNCTION HV_LAS_WRITE_HVS3,list,rootdir,nickname,date_start,date_end,bf_process = bf_process,standard_process = standard_process,details = details
;
; Read in the first and last FITS file
;
;  dummy = readfits(list[0],h1)
;  date_start = (fitshead2struct(h1)).obt_time

;  dummy = readfits(list[n_elements(list)-1],h2)
;  date_end = (fitshead2struct(h2)).obt_time

  HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
  logfilename = HV_LOG_FILENAME_CONVENTION(nickname, date_start, date_end)
  done =  HV_LAS_PROCESS_LIST_BF2(list,rootdir,nickname,subdir + logfilename,details = details)

RETURN,done
END
