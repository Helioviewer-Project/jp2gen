PRO HV_WAIT, progname,t,seconds = seconds, minutes = minutes, hours = hours, days = days
  t = t*1.0
;
; Default is to wait in seconds
;
  unit = 'second'
  f = 1.0
;
; Wait for a set amount of time
;
  if keyword_set(seconds) then begin 
     f = 1.0
     unit = 'second'
  endif
  if keyword_set(minutes) then begin 
     f = 60.0
     unit = 'minute'
  endif
  if keyword_set(hours) then begin 
     f = 60.*60.0
     unit = 'hour'
  endif
  if keyword_set(days) then begin 
     f = 24*60.0*60.0
     unit = 'day'
  endif
  if (t eq 1) then begin
     plural = ''
  endif else begin
     plural = 's'
  endelse
  unit = unit + plural

  print,progname + ': scheduled wait time of ' + trim(t) + ' ' + unit + ' beginning.'
  wait,t*f
  return
end

