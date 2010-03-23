PRO HV_REPEAT_MESSAGE, progname,n,t, more = more
;
; Standard repeat message
;
  print,progname + ': started at '+ t
  print,progname + ': completed repeat number '+trim(n)
  print,progname + ': most recent repeat finished at ' + systime(0)
  if keyword_set(more) then begin
     print,progname + ': ' + more
  endif
  return
end

