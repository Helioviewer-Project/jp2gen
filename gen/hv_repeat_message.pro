PRO HV_REPEAT_MESSAGE, progname,n,t, more = more, web = web
;
; Standard repeat message
;
  print,progname + ': started at '+ t
  print,progname + ': completed repeat number '+trim(n)
  print,progname + ': most recent repeat finished at ' + systime(0)
  if keyword_set(more) then begin
     print,progname + ': ' + more
  endif
;
; Write the message out to the web directory where it will be
; picked up by another script to create a web page showing the latest
; creation details
;
  if keyword_set(web) then begin
     filename = 'latest.' + progname + '.txt'
     dir = storage.web
  endif
  return
end

