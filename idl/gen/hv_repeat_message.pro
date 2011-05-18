PRO HV_REPEAT_MESSAGE, progname,n,t, more = more, web = web
;
; Standard repeat message
;
  if keyword_set(more) then begin
     nm = n_elements(more)
  endif else begin
     nm = 0
  endelse
  a = strarr(3+nm)
;
; standard output
;
  a[0] = progname + ': started at '+ t
  a[1] = progname + ': completed repeat number '+trim(n)
  a[2] = progname + ': most recent repeat finished at ' + systime(0)
;
; print to screen
;
  print,a[0]
  print,a[1]
  print,a[2]
  if keyword_set(more) then begin
     for i = 0,nm-1 do begin
        a[3+i] = progname + ': ' + more[i]
        print,a[3+i]
     endfor
  endif
;
; Write the message out to the web directory where it will be
; picked up by another script to create a web page showing the latest
; creation details
;
  if keyword_set(web) then begin
     storage = HV_STORAGE()
     filename = 'latest.' + progname + '.txt'
     dir = storage.web
     nb = n_elements(a) + 2
     b = strarr(nb)
     b[0] = '<P>'
     b[1:n_elements(a)] = a[*] + '<BR>'
     b[nb-1] = '</P>'
     HV_WRT_ASCII,b,dir + filename
  endif
  return
end

