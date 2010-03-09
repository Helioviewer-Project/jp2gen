;
; Create the subdirectory structure as required
;
;
FUNCTION HV_WRITE_LIST_JP2_MKDIR,hvs,dir,return_path_only = return_path_only

  loc = dir

  if hvs.measurement ne '' then begin
     loc = loc + hvs.measurement + path_sep()
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif

  if hvs.yy ne '' then begin
     loc = loc + hvs.yy + path_sep()
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif
        
  if hvs.mm ne '' then begin
     loc = loc + hvs.mm + path_sep()
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif
        
  if hvs.dd ne '' then begin
     loc = loc + hvs.dd + path_sep()
     if NOT(KEYWORD_SET(return_path_only)) THEN BEGIN
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endif

  return,loc
end
