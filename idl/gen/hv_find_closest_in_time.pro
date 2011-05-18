FUNCTION HV_RETURN_OBS_TIME,file,tag_name = tag_name
  dummy = rfits(file,head=h)
  sh = fitshead2struct(h)
  if tag_exist(sh,'date_obs') then begin
     d = sh.date_obs
  endif else begin
     if keyword_set(tag_name) then begin
        d = gt_tagval(sh,tag_name)
     endif else begin
        d = sh.t_obs
     endelse
  endelse
  return,d
end
;
; 1 Dec 2009
;
; Not hugely smart way of finding the closest entry in time
; to a given time.  Assumes that the entry list is time ordered.  RDS
; is the requested time, passed in seconds (TAI).  Returns the index
; of the relevant entry
; 
FUNCTION HV_FIND_CLOSEST_IN_TIME,list,rds,tag_name = tag_name
  nlist = long(n_elements(list))
  ilo = long(0)
  ihi = nlist-long(1)
  iii = ( 0.5*(long(ihi) - long(ilo) ) )
     
  for i = 0,1+nint(alog(nlist)/alog(2.0)) do begin ; add a wee bit to make sure

     dlo = anytim2tai( HV_RETURN_OBS_TIME(list[ilo],tag_name = tag_name ) )
     dii = anytim2tai( HV_RETURN_OBS_TIME(list[iii],tag_name = tag_name ) )
     dhi = anytim2tai( HV_RETURN_OBS_TIME(list[ihi],tag_name = tag_name ) )

     if ((rds gt dii) and (rds lt dhi)) then begin
        ilo = iii
        iii = nint( 0.5*(ihi - ilo) ) + ilo
     endif
     if ((rds gt dlo) and (rds lt dii)) then begin
        ihi = iii
        iii = nint( 0.5*(ihi - ilo) ) + ilo
     endif
  endfor
  return,iii
end
