;+
; Project     :	TRACE
;
; Name        :	HVS_TRACE()
;
; Purpose     :	Helioviewer device setup file for TRACE
;
; Category    :	TRACE, Helioviewer
;
; Explanation :	Defines the Helioviewer device setup file for TRACE
;
; Syntax      :	Info = HVS_TRACE()
;
; Examples    :	See HV_TRACE_PREP2JP2
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
; History     :	Version 1, 8-October-2013, GSFC
;
; Contact     :	J.Ireland
;-
;
function hvs_trace
;
;  Define the details structure.
;
details = {measurement: '', $
           n_levels: 8, $
           n_layers: 8, $
           idl_bitdepth: 8, $
           bit_rate: [2, 0.01]}
details = replicate(details, 8)
details.measurement = ['171', '195', '284', '1216', '1550', '1600', '1700', 'continuum']
;
;  Define the info structure.
;
info = {observatory: 'TRACE', $
        instrument: 'TRACE', $
        detector: 'TRACE', $
        nickname: 'TRACE', $
        hvs_details_filename: 'hvs_trace.pro', $
        hvs_details_filename_version: '1.0', $
        details: details}
;
return, info
end
