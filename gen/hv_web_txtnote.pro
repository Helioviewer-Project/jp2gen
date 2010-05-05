PRO HV_WEB_TXTNOTE, progname,message,latest = latest,details = details
     prefix = ''
;
; Special prefix
;
  if keyword_set(latest) then begin
     prefix = 'latest.'
  endif
  if keyword_set(details) then begin
     prefix = 'details.'
  endif
;
; write the file
;
  filename = prefix + progname + '.txt'
  storage = HV_STORAGE()
  dir = storage.web
  nb = long(3) + long(n_elements(message))
  b = strarr(nb)
  b[0] = '<P>'
  for i = 1,n_elements(message) do begin
     b[i] = message[i-1] + '<BR>'
  endfor
  b[nb-1] = '</P>'
  HV_WRT_ASCII,b,dir + filename

  return
end

