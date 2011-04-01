;
; Directory Convention
;
FUNCTION HV_DIRECTORY_CONVENTION,yy,mm,dd,measurement
  return,[yy + path_sep(),$
          yy + path_sep() + mm + path_sep(),$
          yy + path_sep() + mm + path_sep() + dd + path_sep(),$
          yy + path_sep() + mm + path_sep() + dd + path_sep() + measurement + path_sep()]
end
