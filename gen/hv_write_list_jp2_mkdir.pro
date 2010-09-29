;
; Create the subdirectory structure as required
;
;
FUNCTION HV_WRITE_LIST_JP2_MKDIR,hvs,dir,return_path_only = return_path_only

  loc = dir

  dirCon = HV_DIRECTORY_CONVENTION(hvs.yy,hvs.mm,hvs.dd,hvs.measurement)

  if hvs.yy ne '' then begin
     loc = loc + dirCon[0]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif
        
  if hvs.mm ne '' then begin
     loc = loc + dirCon[1]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif
        
  if hvs.dd ne '' then begin
     loc = loc + dirCon[2]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif

  if hvs.measurement ne '' then begin
     loc = loc + dirCon[3]
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif

  return,loc
end
