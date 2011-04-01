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

  done =  HV_LAS_PROCESS_LIST_BF2(list,rootdir,nickname,'dummy',details = details)

RETURN,done
END
