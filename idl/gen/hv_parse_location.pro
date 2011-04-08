;
; 5 May 2010
;
; Parse a filename
;
FUNCTION HV_PARSE_LOCATION,a, $
                           transfer_path = transfer_path,$
                           location = location,$
                           all_subdir = all_subdir
;
  progname = 'HV_PARSE_LOCATION'
;
  z = STRSPLIT(EXPAND_TILDE(a),path_sep(),/extract)
  nz = n_elements(z)
;
; To transfer a file you need information from the nickname down.
;
  if keyword_set(transfer_path) then begin
     tp = ''
     IF (nz lt 5) then begin
        print,progname + ': not enough information to create a transfer path. Stopping.'
        stop
     ENDIF ELSE BEGIN
        FOR i = nz-1,nz-6,-1 DO BEGIN
           IF (i eq (nz-1)) THEN BEGIN
              eee = ''
           ENDIF ELSE BEGIN
              eee = path_sep()
           ENDELSE
           tp = z[i] + eee + tp
        ENDFOR
     ENDELSE
     answer = tp
  endif
;
; Get the location above the device nickname
;
  IF keyword_set(location) THEN BEGIN
     tp = ''
     zz = reverse(z)
     FOR i = 6,nz-1 DO BEGIN
        tp = zz[i] + path_sep() + tp
     ENDFOR
     answer = path_sep() + tp
  ENDIF
;
; Return 
;
  IF keyword_set(all_subdir) then begin
     z = strsplit(answer,path_sep(),/extract)
     nz = n_elements(z)
     ddd = strarr(nz)
     ddd[0] = z[0] + path_sep()
     for i = 1, nz-1 do begin
        if i eq (nz-1) then begin
           eee = ''
        endif else begin
           eee = path_sep()
        endelse
        ddd[i] = ddd[i-1] + z[i] + eee
     endfor
     answer = ddd
  endif

  return,answer
END
