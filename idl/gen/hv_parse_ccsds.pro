;
; Parse an input CCSDS time into its parts
;
FUNCTION HV_PARSE_CCSDS,a
  milli = strmid(a,20,3)
  ContainsZ = strpos(milli,'Z')
  if ContainsZ ne -1 then begin
    strput,milli,'5',ContainsZ
  endif
  
  b = {yy:strmid(a,0,4),$
       mm:strmid(a,5,2),$
       dd:strmid(a,8,2),$
       hh:strmid(a,11,2),$
       mmm:strmid(a,14,2),$
       ss:strmid(a,17,2),$
       milli:milli}
return,b
end
