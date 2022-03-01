;
; Create the subdirectory structure as required
;
;
FUNCTION HV_WRITE_LIST_JP2_MKDIR,hvsi, dir, return_path_only=return_path_only

  dirCon = HV_DIRECTORY_CONVENTION(hvsi.yy, hvsi.mm, hvsi.dd, hvsi.measurement)
  n = n_elements(dirCon)

  for i = 0,n-1 do begin
     nextDir = dir + dirCon[i]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        ;if not(is_dir(nextDir)) then spawn,'mkdir '+ nextDir
        if not(is_dir(nextDir)) then file_mkdir,nextDir
     endif
  endfor

  return,dir + dirCon[n-1]
end
