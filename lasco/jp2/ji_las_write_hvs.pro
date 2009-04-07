;
; Take a list of LASCO files and write them out to HVS format
;
; Return the filenames
;
FUNCTION JI_LAS_WRITE_HVS,dir,filename,rootdir,c1 = c1,c2 = c2, c3 = c3,write = write

  list = ji_read_txt_list(dir + filename)
  n = n_elements(list)
  done = strarr(n)
;  if keyword_set(c1) then begin
;     for i = 0,n-1 do begin
;        done(i) = JI_LAS_C1_WRITE_HVS(list(i),rootdir,write = write)
;     endfor
;  endif
  if keyword_set(c2) then begin
     for i = 0,n-1 do begin
        done(i) = JI_LAS_C2_WRITE_HVS(list(i),rootdir,write = write)
     endfor
  endif
  if keyword_set(c3) then begin
     for i = 0,n-1 do begin
        done(i) = JI_LAS_C3_WRITE_HVS(list(i),rootdir,write = write)
     endfor
  endif

RETURN,done
END
