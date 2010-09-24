;
; Function which defines the MDI JP2 encoding parameters for each type
; of measurement
;
; Minimum required Helioviewer Setup (HVS) structure tags.
;
; Let us assume there is a device commonly known by its "nickname",
; but is actually a "detector" which is part of an "instrument" on a
; space or ground based "observatory".  There are "N" different
; measurements possible from the device.  The tags below are the
; minimum required.
;
; a = {observatory: 'AAA',$
;      instrument: 'BBB',$
;      detector: 'CCC',$
;      nickname: 'DDD',$
;      hvs_details_filename: 'XXX',$
;      hvs_details_filename_version: 'Y.Z',$
;      details(N)}
;
; For each of the N measurements, there is a details structure.  The
; structure of the details structure is identical for every
; measurement, but the values can be different for each
; measurement. The tags below are the minimum required.
;
;
; details = {measurement: 'EEE',$
;            n_levels: F,$
;            n_laters: G,$
;            idl_bitdepth: H,$
;            bit_rate: [I,J]}
;
;

FUNCTION HVS_HIGHBITRATE_MDI
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [8.0,0.01]}
;
; In this case, each MDI measurement requires the same type of details
;
  a = replicate( d , 2 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'SOHO',$ ; REQUIRED
       instrument:'MDI',$ ; REQUIRED
       detector:'MDI',$ ; REQUIRED
       nickname:'MDI',$ ; REQUIRED
       hvs_details_filename:'hvs_highbitrate_mdi.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0',$ ; REQUIRED
       quicklook_directory:'/service/soho-archive/home/soho/private/data/planning/mdi',$ ; OPTIONAL - if you have quicklooks available, store their location in this variable.  This variable is required to run HV_MDI_PREP2JP2_QL.PRO
       flatfield_file:'/service/soho-archive/home/sdb/soho/mdi/flatfield/flat_May2010.fits'} ; OPTIONAL - use this flat field file if it is not in the rest of your IDL path.  This variable is required to run HV_MDI_PREP2JP2_QL.PRO

;
; Warning!  Do not swap the order of these measurements.  White-light
; must remain at b.details[0] and continuum at b.details[1]
;
;
; white-light
;
  b.details[0].measurement = 'continuum'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [8.0,0.01] ; REQUIRED
;
; longitudinal magnetic field
;
  b.details[1].measurement = 'magnetogram'; REQUIRED
  b.details[1].n_levels = 8 ; REQUIRED
  b.details[1].n_layers = 8 ; REQUIRED
  b.details[1].idl_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [8.0,0.01] ; REQUIRED

  return,b
end 
