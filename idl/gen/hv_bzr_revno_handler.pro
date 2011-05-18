;
; 24 Nov 2009
;
; Function to handle the output from the command
; bzr revno
;
FUNCTION HV_BZR_REVNO_HANDLER,loc
  spawn,['bzr','revno',loc], list,err,/noshell
  if err[0] eq '' then begin
     out = list
  endif else begin
     wby = HV_WRITTENBY()
     out ='No valid revision number found. Bazaar not installed? Using HV_WRITTENBY manually included revision number: '+ wby.manual_revision_number + ' : ' + strjoin(err,':')
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
