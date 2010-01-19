;
; Return,year,month,day,hour,minute,second from an input time.  Takes
; care of the issue that MDI sometimes reports the second field in
; DATE_OBS as '60'
;
; input = time t in the format '2003-05-11T22:22:60.000Z'
;
FUNCTION HV_FIX_TIME,t,hvstring = hvstring
  s = int2utc(anytim2utc(t))
  if keyword_set(hvstring) then begin
     hv = {yy:'',mm:'',dd:'',hh:'',mmm:'',ss:'',date_obs:''}
     hv.yy = trim(s.year)

     if (s.month lt 10) then begin
        hv.mm = '0' + trim(s.month)
     endif else begin
        hv.mm = trim(s.month)
     endelse

     if (s.day lt 10) then begin
        hv.dd = '0' + trim(s.day)
     endif else begin
        hv.dd = trim(s.day)
     endelse

     if (s.hour lt 10) then begin
        hv.hh = '0' + trim(s.hour)
     endif else begin
        hv.hh = trim(s.hour)
     endelse

     if (s.minute lt 10) then begin
        hv.mmm = '0' + trim(s.minute)
     endif else begin
        hv.mmm = trim(s.minute)
     endelse

     if (s.second lt 10) then begin
        hv.ss = '0' + trim(s.second)
     endif else begin
        hv.ss = trim(s.second)
     endelse
     hv.date_obs = hv.yy + '-' + hv.mm + '-' + hv.dd + 'T' + $
                   hv.hh + ':' + hv.mmm +':' + hv.ss + $
                   '.000Z'

     return,hv
  endif else begin
     return,s
  endelse
end
