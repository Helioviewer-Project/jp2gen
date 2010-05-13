;
; 14 May 2010
;
; return true/false to see if we are using a quicklook processing stream
;
FUNCTION HV_USING_QUICKLOOK_PROCESSING,called_by
  a1 = STRPOS(strupcase(called_by),'QL')
  a2 = STRPOS(strupcase(called_by),'QUICKLOOK')

  tf = 0
  IF( (a1[0] ge 0) OR (a2[0] ge 0) ) then begin
     tf = 1
  ENDIF

  return,tf
end
