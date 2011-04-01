;
; Create the subdirectory structure as required
;
;
FUNCTION HV_WRITE_LIST_JP2_MKDIR,hvs,dir,return_path_only = return_path_only

  dirCon = HV_DIRECTORY_CONVENTION(hvs.yy,hvs.mm,hvs.dd,hvs.measurement)
  n = n_elements(dirCon)

  for i = 0,n-1 do begin
     nextDir = dir + dirCon[i]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(nextDir)) then spawn,'mkdir '+ nextDir
     endif
  endfor

  return,dir + dirCon[n-1]
end
