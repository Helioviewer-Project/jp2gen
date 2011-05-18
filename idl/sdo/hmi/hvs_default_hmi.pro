;
; Function which defines the EIT JP2 encoding parameters for each type
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

FUNCTION HVS_DEFAULT_HMI
;
; Get some general setup details.
;
  g = HVS_GEN()
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01],dataMin:0.0,dataMax:0.0,dataScalingType:0}
;
; In this case, each AIA measurement requires the same type of details
;
  a = replicate( d , 10 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'SDO',$ ; REQUIRED
       instrument:'HMI',$ ; REQUIRED
       detector:'HMI',$ ; REQUIRED
       nickname:'HMI',$ ; REQUIRED
       hvs_details_filename:'hvs_default_hmi.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0'} ; REQUIRED
;
; Scaling algorithm
;
; get the image: A
; normalize the exposure: A/dataExptime = B
; clip: B>dataMin <dataMax = C
; byte scaling: BYTSCL(C) = D
;
; For HMI the exposure normalization step is skipped.  This is equivalent
; to having a dataExptime = 1.0

;
; CONTINUUM INTENSITY
;
  b.details[0].measurement = 'continuum'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[0].dataMin = 0.0
  b.details[0].dataMax = 500000.0
  b.details[0].dataScalingType = 0 ; 0 - linear, 1 - sqrt, 3 - log10
;
; LONGITUDINAL MAGNETOGRAM
;
  b.details[1].measurement = 'magnetogram'; REQUIRED
  b.details[1].n_levels = 8 ; REQUIRED
  b.details[1].n_layers = 8 ; REQUIRED
  b.details[1].idl_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[1].dataMin = -250.0
  b.details[1].dataMax = 250.0
  b.details[1].dataScalingType = 0 ; 0 - linear, 1 - sqrt, 3 - log10

;
; Verify
;
  verify = { naxis1:  { default:4096, accept:{type:g.exact,value:[4096]} },$
             naxis2:  { default:4096, accept:{type:g.exact,value:[4096]} }}

  b = add_tag(b,verify,'verify')
  return,b
end 
