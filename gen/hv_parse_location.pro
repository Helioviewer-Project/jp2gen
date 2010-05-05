;
; 5 May 2010
;
; Parse a filename
;
FUNCTION HV_PARSE_LOCATION,a, $
                           transfer_path = transfer_path,$
                           location = location
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
        FOR i = nz-1,5,-1 DO BEGIN
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

  return,answer
END
