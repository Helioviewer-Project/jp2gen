;
; Function to test if the file is Helioviewer compliant.
; This function is not complete yet
;
; file is compliant?  Return compliance = 1
; file is not compliant? Return compliance = 0
;
; The initial assumption is that the file is compliant
;
FUNCTION HV_COMPLIANCE,hvs
  ;
  ; Assume that the file is compliance
  ;
  compliance = 1

  ;
  ; Test that the time is understandable
  ;
  ;yy = hvs.hvsi.yy

  RETURN, compliance
END
