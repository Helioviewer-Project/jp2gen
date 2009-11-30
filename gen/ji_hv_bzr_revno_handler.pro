;
; 24 Nov 2009
;
; Function to handle the output from the command
; bzr revno
;
FUNCTION JI_HV_BZR_REVNO_HANDLER,loc
  spawn,['bzr','revno',loc], list,err,/noshell
  if err eq '' then begin
     out = list
  endif else begin
     out ='No valid revision number found. '+ err
  endelse

;  if isarray(out) then begin
;     bzr_revno = ''
;     for i = 0,n_elements(out)-1 do begin
;        bzr_revno = bzr_revno + out[i] + '_'
;     endfor
;  endif else begin
;     bzr_revno = out
;  endelse
  return,out
end
