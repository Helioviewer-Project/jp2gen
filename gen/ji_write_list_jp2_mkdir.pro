;
; Create the subdirectory structure as required
;
;
FUNCTION JI_WRITE_LIST_JP2_MKDIR,hvs,dir,observer_subdir = observer_subdir
  loc = dir

  if keyword_set(observer_subdir) then begin
     loc = loc + hvs.observatory + '-' + hvs.instrument + '-' + hvs.detector + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif

  loc = loc + hvs.yy + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.mm + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.dd + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.observatory + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.instrument + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.detector + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc
        
  loc = loc + hvs.measurement + '/'
  if not(is_dir(loc)) then spawn,'mkdir '+ loc

  return,loc
end
