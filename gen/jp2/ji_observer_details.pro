;
; Pass in an observer and measurement, and get the JP2 encoding options
;
FUNCTION JI_OBSERVER_DETAILS,observer,measurement
;
; Supported observers, usually an observatory/instrument/detector
; triplet, and their properties
;
  supported = {observer:strarr(4)}
  supported.observer[0] = 'SOH_EIT_EIT'
  supported.observer[1] = 'SOH_MDI_MDI'
  supported.observer[2] = 'SOH_LAS_0C2'
  supported.observer[3] = 'SOH_LAS_0C3'
;
; Default jp2 encoding options
;
  jp2_default = {n_layers:8,n_levels:8,bit_rate:[0.5,0.01]}
;
; Is the passed observer supported?
;
  observer_index = (where(observer eq supported.observer))[0]
;
; If so, continue
;
  if ( observer_index ne -1) then begin
     supported_yn = 1
     case observer_index of
;
; SOH_EIT_EIT
;
        0: case measurement of
           '304': jp2 = jp2_default
           '171': jp2 = jp2_default
           '195': jp2 = jp2_default
           '284': jp2 = jp2_default
        endcase
;
; SOH_MDI_MDI
;
        1: case measurement of
           'int': jp2 = jp2_default
           'mag': jp2 = jp2_default
        endcase
;
; SOH_LAS_0C2  
;
        2:  case measurement of
           '0WL': jp2 = jp2_default
        endcase
;
; SOH_LAS_0C3  
;
        3:  case measurement of
           '0WL': jp2 = {n_layers:8,n_levels:8,bit_rate:[4.0,0.01]}
        endcase

     endcase
  endif else begin
     supported_yn = 0
     jp2 = jp2_default
  endelse
;
; Return the selection
;
  answer = {supported_yn:supported_yn,jp2:jp2}
  return,answer
end
