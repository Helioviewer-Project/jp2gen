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
FUNCTION JI_LAS_WRITE_HVS,dir,filename,rootdir,c1 = c1,c2 = c2, c3 = c3,write = write,bf_process = bf_process,standard_process = standard_process

;  list = ji_read_txt_list(dir + filename)
  restore,dir + filename
  n = n_elements(list)
  done = strarr(n)
;  if keyword_set(c1) then begin
;     for i = 0,n-1 do begin
;        done(i) = JI_LAS_C1_WRITE_HVS(list(i),rootdir,write = write)
;     endfor
;  endif
  if keyword_set(c2) then begin
     for i = 0,n-1 do begin
        done(i) = JI_LAS_C2_WRITE_HVS(list(i),rootdir,write = write,bf_process = bf_process,standard_process = standard_process)
     endfor
  endif
  if keyword_set(c3) then begin
     for i = 0,n-1 do begin
        done(i) = JI_LAS_C3_WRITE_HVS(list(i),rootdir,write = write,bf_process = bf_process,standard_process = standard_process)
     endfor
  endif

RETURN,done
END
