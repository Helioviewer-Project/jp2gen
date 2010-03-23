PRO HV_REPEAT_MESSAGE, progname,n,t,wait=wait
;
; Wait 15 minutes before looking for more data
;
  print,progname + ': started at '+ t
  print,progname + ': completed repeat number '+trim(n)
  if keyword_set(wait) then begin
     print,progname + ': Fixed wait time of '+trim(wait)+' seconds now progressing.'
  endif

