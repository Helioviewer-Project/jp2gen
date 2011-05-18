;+
; Project     :	STEREO - SECCHI
;
; Name        :	HVS_COR1_A()
;
; Purpose     :	Helioviewer device setup file for STEREO/COR1-A
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Defines the Helioviewer device setup file for COR1 on STEREO-A
;
; Syntax      :	Info = HVS_COR1_A()
;
; Examples    :	See HV_COR1_PREP2JP2
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	Result of the function is the Helioviewer info structure
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 22-Dec-2010, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
function hvs_cor1_a
;
;  Define the details structure.
;
details = {measurement: 'white-light', $
           n_levels: 8, $
           n_layers: 8, $
           idl_bitdepth: 8, $
           bit_rate: [2, 0.01]}
;
;  Define the info structure.
;
info = {observatory: 'STEREO_A', $
        instrument: 'SECCHI', $
        detector: 'COR1', $
        nickname: 'COR1-A', $
        hvs_details_filename: 'hvs_cor1_a.pro', $
        hvs_details_filename_version: '1.0', $
        details: details}
;
return, info
end
