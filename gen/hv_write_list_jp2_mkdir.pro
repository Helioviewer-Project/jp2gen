;
; Create the subdirectory structure as required
;
;
FUNCTION HV_WRITE_LIST_JP2_MKDIR,hvs,dir,$
                                    observer_subdir = observer_subdir,$
                                    original = original ; choose the original subdirectory structure
  loc = dir

  if not(keyword_set(original)) then begin
;     if hvs.details.nickname ne '' then begin
;        loc = loc + hvs.details.nickname + path_sep()
;        if not(is_dir(loc)) then spawn,'mkdir '+ loc
;     endif

     if hvs.measurement ne '' then begin
        loc = loc + hvs.measurement + path_sep()
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

  endif else begin
     if keyword_set(observer_subdir) then begin
        loc = loc + $
              hvs.details.observatory + '-' + $
              hvs.details.instrument + '-' + $
              hvs.details.detector + path_sep()
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
        
     if hvs.details.observatory ne '' then begin
        loc = loc + hvs.details.observatory + path_sep()
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
        
     if hvs.details.instrument ne '' then begin
        loc = loc + hvs.details.instrument + path_sep()
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
        
     if hvs.details.detector ne '' then begin
        loc = loc + hvs.details.detector + path_sep()
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
        
     if hvs.measurement ne '' then begin
        loc = loc + hvs.measurement + path_sep()
        if not(is_dir(loc)) then spawn,'mkdir '+ loc
     endif
  endelse

  return,loc
end
