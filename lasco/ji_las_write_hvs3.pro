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
FUNCTION JI_LAS_WRITE_HVS3,list,rootdir,c1 = c1,c2 = c2, c3 = c3,write = write,bf_process = bf_process,standard_process = standard_process
;
  if keyword_set(c2) then begin
     done =  JI_LAS_PROCESS_LIST_BF2(list,rootdir,'c2')
  endif
  if keyword_set(c3) then begin
     done =  JI_LAS_PROCESS_LIST_BF2(list,rootdir,'c3')
  endif

RETURN,done
END
