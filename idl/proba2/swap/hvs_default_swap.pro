;
; Function which defines the SWAP JP2 encoding parameters for each type
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

FUNCTION HVS_DEFAULT_SWAP
;
; Get some general setup details.
;
  g = HVS_GEN()
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [4.0,0.01],dataMin:0.0,dataMax:0.0,dataScalingType:0}
;
; In this case, each AIA measurement requires the same type of details
;
  a = replicate( d , 1 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'PROBA2',$ ; REQUIRED
       instrument:'SWAP',$ ; REQUIRED
       detector:'SWAP',$ ; REQUIRED
       nickname:'SWAP',$ ; REQUIRED
       hvs_details_filename:'hvs_default_swap.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0'} ; REQUIRED
;
; 174
;
  b.details[0].measurement = '174'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [4.0,0.01] ; REQUIRED
  b.details[0].dataMin = 0.0
  b.details[0].dataMax = 800.0
  b.details[0].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10
;
; Verify
;
;  verify = { naxis1:  { default:4096, accept:{type:g.exact,value:[4096]} },$
;             naxis2:  { default:4096, accept:{type:g.exact,value:[4096]} }}
;
;  b = add_tag(b,verify,'verify')
  return,b
end 
