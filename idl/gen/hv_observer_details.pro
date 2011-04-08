;
; Pass in an observer and measurement, and get the JP2 encoding options
;
FUNCTION HV_OBSERVER_DETAILS,observer,measurement,hvs_filename
  
  details = CALL_FUNCTION(hvs_filename)
  w = where(details.measurement eq measurement)
  if (w eq -1) then begin
     supported_yn = 0
     jp2 = {n_layers:8,n_levels:8,bit_rate:[0.5,0.01],idl_bitdepth: 8} ; default
  endif else begin
     jp2 = details[w]
     supported_yn = 1
  endelse

;
; Supported observers, usually an observatory/instrument/detector
; triplet, and their properties
;
;;   nicknames = (HV_OIDM2('EIT')).nicknames
;;   nn = n_elements(nicknames)
;;   supported = {observer:strarr(nn)}
;;   for i = 0,nn-1 do begin
;;      oidm = HV_OIDM2(nicknames[i])
;;      supported.observer[i] = oidm.observatory + '_' + $
;;                              oidm.instrument + '_' + $
;;                              oidm.detector
;;   endfor
;; ;
;; ; Default jp2 encoding options
;; ;

;; ;
;; ; Is the passed observer supported?
;; ;
;;   observer_index = (where(observer eq supported.observer))[0]
;; ;
;; ; If so, continue
;; ;
;;   if (observer_index ne -1) then begin
;;      name = nicknames[observer_index]
;;      supported_yn = 1

;;      details = CALL_FUNCTION(hvs_filename)
;;      w = where(details.measurement eq measurement)
;;      jp2 = details[w]
;
; ##############################################################################
;
;                            SOHO
;
; EIT
;
;;      case name of
;;         'EIT':   case measurement of
;;            '304': jp2 = jp2_default
;;            '171': jp2 = jp2_default
;;            '195': jp2 = jp2_default
;;            '284': jp2 = jp2_default
;;         endcase
;; ;
;; ; MDI
;; ;
;;         'MDI': case measurement of 
;;            'continuum': jp2 = jp2_default
;;            'magnetogram': jp2 = jp2_default
;;         endcase
;; ;
;; ; LASCO C2
;; ;
;;         'LASCO-C2': case measurement of
;;            'white-light': jp2 = jp2_default
;;         endcase
;; ;
;; ; LASCO C3
;; ;
;;         'LASCO-C3': case measurement of
;;            'white-light': jp2 = {n_layers:8,n_levels:8,bit_rate:[4.0,0.01],idl_bitdepth: 8}
;;         endcase
;; ;
;; ; ##############################################################################
;; ;
;; ;                            STEREO-A
;; ;
;; ; EUVI-A
;; ;
;;         'EUVI-A':   case measurement of
;;            '304': jp2 = jp2_default
;;            '171': jp2 = jp2_default
;;            '195': jp2 = jp2_default
;;            '284': jp2 = jp2_default
;;         endcase
;; ;
;; ; COR1-A
;; ;
;;         'COR1-A': case measurement of
;;            'white-light': jp2 = jp2_default
;;         endcase
;; ;
;; ; COR2-A
;; ;
;;         'COR2-A': case measurement of
;;            'white-light': jp2 = jp2_default
;;         endcase
;; ;
;; ; ##############################################################################
;; ;
;; ;                            STEREO-B
;; ;
;; ; EUVI-B
;; ;
;;         'EUVI-B':   case measurement of
;;            '304': jp2 = jp2_default
;;            '171': jp2 = jp2_default
;;            '195': jp2 = jp2_default
;;            '284': jp2 = jp2_default
;;         endcase
;; ;
;; ; COR1-B
;; ;
;;         'COR1-B': case measurement of
;;            'white-light': jp2 = jp2_default
;;         endcase
;; ;
;; ; COR2-B
;; ;
;;         'COR2-B': case measurement of
;;            'white-light': jp2 = jp2_default
;;         endcase
;; ;
;; ; ##############################################################################
;; ; Include details on the JP2 encoding of each measurement of the ZAP-C device
;; ; 
;; ; See the wiki page 
;; ; http://www.helioviewer.org/wiki/index.php?title=Converting_FITS_to_JP2_for_the_Helioviewer_Project
;; ; for more details
;; ;
;; ;                            MAXWELL-C
;; ;
;; ; ZAP-C
;; ;
;; ;        'ZAP-C':   case measurement of
;; ;           '1600': jp2 = jp2_default
;; ;           'WL': jp2 = {n_layers:4,n_levels:4,bit_rate:[8.0,0.01],idl_bitdepth: 8}
;; ;           '195': jp2 = jp2_default
;; ;           'polarity': jp2 = {n_layers:6,n_levels:16,bit_rate:[3.0,0.1],idl_bitdepth: 8}
;; ;        endcase

;;      endcase
;;   endif else begin
;;      supported_yn = 0
;;      jp2 = jp2_default
;;   endelse
;
; Return the selection
;
  answer = {supported_yn:supported_yn,jp2:jp2}
  return,answer
end
