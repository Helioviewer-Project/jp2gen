;+
; Project     :	STEREO - SECCHI
;
; Name        :	HVS_COR2_B()
;
; Purpose     :	Helioviewer device setup file for STEREO/COR2-B
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Defines the Helioviewer device setup file for COR2 on STEREO-B
;
; Syntax      :	Info = HVS_COR2_B()
;
; Examples    :	See HV_COR2_PREP2JP2
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
function hvs_cor2_b
;
;  Define the details structure.
;
details = {measurement: 'white-light', $
           n_levels: 8, $
           n_layers: 8, $
           idl_bitdepth: 8, $
           bit_rate: [0.5, 0.01]}
;
;  Define the info structure.
;
info = {observatory: 'STEREO_B', $
        instrument: 'SECCHI', $
        detector: 'COR2', $
        nickname: 'COR2-B', $
        hvs_details_filename: 'hvs_cor2_b.pro', $
        hvs_details_filename_version: '1.0', $
        details: details}
;
return, info
end
