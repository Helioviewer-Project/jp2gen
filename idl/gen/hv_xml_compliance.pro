;
; Very simple check that the input is compliant with XML standards and
; escape it if need be
;
FUNCTION HV_XML_COMPLIANCE,input
  answer = str_replace(input,'<','&lt;')
  answer = str_replace(answer,'>','&gt;')
  answer = str_replace(answer,'&','&amp;')
;  answer = str_replace(answer,'','&apos')
  answer = str_replace(answer,'"','&quot;')

  return,answer
end
