;
; Take a list of MDI files and write them out to HVS format
;
; Return the filenames
;
FUNCTION JI_MDI_WRITE_HVS,dir,filename,rootdir,int = int, mag = mag

  list = ji_read_txt_list(dir + filename)
  n = n_elements(list)
  done = strarr(n)
  if keyword_set(int) then begin
     for i = 0,n-1 do begin
        done(i) = JI_MDI_INT_WRITE_HVS(list(i),rootdir)
     endfor
  endif
  if keyword_set(mag) then begin
     for i = 0,n-1 do begin
        done(i) = JI_MDI_MAG_WRITE_HVS(list(i),rootdir)
     endfor
  endif


RETURN,done
END
