;
; Store some further LASCO image processing details
;
FUNCTION HV_LASCO_IP,c2=c2,c3=c3,c1=c1
;
; C1
;
  if keyword_set(c1) then begin
     gamma = 1.0
  endif
;
; C2
;
  if keyword_set(c2) then begin
     gamma = 1.0
  endif
;
; C3
;
  if keyword_set(c3) then begin
     gamma = 0.380
  endif

return,{gamma:gamma}
end
