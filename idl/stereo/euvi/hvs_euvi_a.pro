;+
; Project     :	STEREO - SECCHI
;
; Name        :	HVS_EUVI_A()
;
; Purpose     :	Helioviewer device setup file for STEREO/EUVI-A
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Defines the Helioviewer device setup file for EUVI on STEREO-A
;
; Syntax      :	Info = HVS_EUVI_A()
;
; Examples    :	See HV_EUVI_PREP2JP2
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
function hvs_euvi_a
;
;  Define the details structure for each wavelength.
;
details = {measurement: '', $
           n_levels: 8, $
           n_layers: 8, $
           idl_bitdepth: 8, $
           bit_rate: [0.5, 0.01]}
details = replicate(details, 4)
details.measurement = ['171','195','284','304']
;
;  Define the info structure.
;
info = {observatory: 'STEREO_A', $
        instrument: 'SECCHI', $
        detector: 'EUVI', $
        nickname: 'EUVI-A', $
        hvs_details_filename: 'hvs_euvi_a.pro', $
        hvs_details_filename_version: '1.0', $
        details: details}
;
return, info
end
