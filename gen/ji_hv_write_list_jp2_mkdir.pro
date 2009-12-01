;
; Create the subdirectory structure as required
;
;
FUNCTION JI_HV_WRITE_LIST_JP2_MKDIR,hvs,dir,observer_subdir = observer_subdir
  loc = dir

  if keyword_set(observer_subdir) then begin
     loc = loc + hvs.observatory + '-' + hvs.instrument + '-' + hvs.detector + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif

  if hvs.yy ne '' then begin
     loc = loc + hvs.yy + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.mm ne '' then begin
     loc = loc + hvs.mm + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.dd ne '' then begin
     loc = loc + hvs.dd + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.observatory ne '' then begin
     loc = loc + hvs.observatory + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.instrument ne '' then begin
     loc = loc + hvs.instrument + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.detector ne '' then begin
     loc = loc + hvs.detector + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.measurement ne '' then begin
     loc = loc + hvs.measurement + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif

  return,loc
end
