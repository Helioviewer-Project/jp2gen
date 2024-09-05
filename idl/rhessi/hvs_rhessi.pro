;+
; Project     : Helioviewer
;
; Name        : HVS_RHESSI()
;
; Purpose     : Helioviewer device setup file for RHESSI
;
; Category    : RHESSI, Helioviewer
;
; Explanation : Defines the Helioviewer device setup file for RHESSI
;
; Syntax      : Info = HVS_RHESSI()
;
; Examples    : See HV_RHESSI_MAKE_JP2
;
; Inputs      : None.
;
; Opt. Inputs : None.
;
; Outputs     : Result of the function is the Helioviewer info structure
;
; Opt. Outputs: None.
;
; Keywords    : None.
;
; Calls       : None.
;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; Prev. Hist. : None.
; 
; Written: Kim Tolbert 05-Nov-2020. Based on J. Ireland's hvs_rhessi_quicklook.pro
;
; History     : Version 1, Nov 2020, GSFC
; 2024/03/08 - Kim Tolbert. Added new field to hvs structure - multi_image_fitsfile - used in hv_db.pro.
;   For cases where more than one jp2 file is created from a single FITS file.
;
;-

function hvs_rhessi
  
  ; Get some general setup details.
  
;  g = HVS_GEN()   ; ask Jack - do we need this?
  
  ; Each measurement requires some details to control the creation of JP2 files
  
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [8.0,0.01], eband: [0.0, 0.0]}
  
  ; In this case, each RHESSI measurement requires the same type of details
  
  a = replicate( d , 6 )
  
  ebands = get_edges([3.,6.,12.,25.,50.,100.,300.], /edges_2)
  s_ebands = str_replace(format_intervals(ebands,format='(i3)'), ' to ', '-') + 'keV'
  a.measurement = s_ebands
  a.eband = ebands
  
  ; Full description
  
  b = {details:a,$  ; REQUIRED
    observatory:'RHESSI',$ ; REQUIRED
    instrument:'RHESSI',$ ; REQUIRED
    detector:'',$ ; REQUIRED  Fill in with image reconstruction method later
    nickname:'RHESSI',$ ; REQUIRED
    hvs_details_filename:'hvs_rhessi.pro',$ ; REQUIRED
    hvs_details_filename_version:'1.0', $
    fractional_contour_levels: [0.3, 0.5, 0.68, 0.95, 0.99], $
    contour_level_names: ['30%', '50%', '68%', '95%', '99%'], $
    multi_image_fitsfile: 1}

  return, b
END