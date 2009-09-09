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

  if hvs.yy ne '' then begin
     loc = loc + hvs.yy + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.mm ne '' then begin
     loc = loc + hvs.mm + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.dd ne '' then begin
     loc = loc + hvs.dd + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.observatory ne '' then begin
     loc = loc + hvs.observatory + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.instrument ne '' then begin
     loc = loc + hvs.instrument + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.detector ne '' then begin
     loc = loc + hvs.detector + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif
        
  if hvs.measurement ne '' then begin
     loc = loc + hvs.measurement + '/'
     if not(is_dir(loc)) then spawn,'mkdir '+ loc
  endif

  return,loc
end
