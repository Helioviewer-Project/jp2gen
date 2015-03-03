;+
; Project     :	Helioviewer
;
; Name        :	HVS_RHESSI_QUICKLOOK()
;
; Purpose     :	Helioviewer device setup file for RHESSI
;
; Category    :	RHESSI, Helioviewer
;
; Explanation :	Defines the Helioviewer device setup file for RHESSI
;
; Syntax      :	Info = HVS_RHESSI_QUICKLOOK()
;
; Examples    :	See HV_RHESSI_QUICKLOOK_PREP2JP2
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
; History     :	Version 1, March 2015, GSFC
;
; Contact     :	J.Ireland
;-
;
function hvs_rhessi_quicklook
;
; Get some general setup details.
;
  g = HVS_GEN()
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [8.0,0.01], eband: [0.0, 0.0]}
;
; In this case, each RHESSI measurement requires the same type of details
;
  a = replicate( d , 6 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'RHESSI',$ ; REQUIRED
       instrument:'RHESSI',$ ; REQUIRED
       detector:'RHESSI',$ ; REQUIRED
       nickname:'RHESSI',$ ; REQUIRED
       hvs_details_filename:'hvs_rhessi_quicklook.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0', $
       fractional_contour_levels: [0.3, 0.5, 0.68, 0.95, 0.99], $
       contour_level_names: ['30%', '50%', '68%', '95%', '99%']}
;
; 3-6 keV
;
  b.details[0].measurement = '3-6keV'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [8.0,0.01] ; REQUIRED
  b.details[0].eband = [3.0, 6.0] ; REQUIRED
;
; 6-12 keV
;
  b.details[1].measurement = '6-12keV'
  b.details[1].n_levels = 8
  b.details[1].n_layers = 8
  b.details[1].idl_bitdepth = 8
  b.details[1].bit_rate = [8.0,0.01]
  b.details[1].eband = [6.0, 12.0]

;
; 12-25 keV
;
  b.details[2].measurement = '12-25keV'
  b.details[2].n_levels = 8
  b.details[2].n_layers = 8
  b.details[2].idl_bitdepth = 8
  b.details[2].bit_rate = [8.0,0.01]
  b.details[2].eband = [12.0, 25.0]

;
; 25-50 keV
;
  b.details[3].measurement = '25-50keV'
  b.details[3].n_levels = 8
  b.details[3].n_layers = 8
  b.details[3].idl_bitdepth = 8
  b.details[3].bit_rate = [8.0,0.01]
  b.details[3].eband = [25.0, 50.0]

;
; 50-100 keV
;
  b.details[4].measurement = '50-100keV'
  b.details[4].n_levels = 8
  b.details[4].n_layers = 8
  b.details[4].idl_bitdepth = 8
  b.details[4].bit_rate = [8.0,0.01]
  b.details[4].eband = [50.0, 100.0]

;
; 100-300 keV
;
  b.details[5].measurement = '100-300keV'
  b.details[5].n_levels = 8
  b.details[5].n_layers = 8
  b.details[5].idl_bitdepth = 8
  b.details[5].bit_rate = [8.0,0.01]
  b.details[5].eband = [100.0, 300.0]

  return, b
END
