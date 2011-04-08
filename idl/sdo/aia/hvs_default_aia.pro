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

FUNCTION HVS_DEFAULT_AIA
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
       instrument:'AIA',$ ; REQUIRED
       detector:'AIA',$ ; REQUIRED
       nickname:'AIA',$ ; REQUIRED
       hvs_details_filename:'hvs_default_aia.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0'} ; REQUIRED
;
; 94
;
  b.details[0].measurement = '94'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[0].dataMin = 0.0
  b.details[0].dataMax = 800.0
  b.details[0].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 131
;
  b.details[1].measurement = '131'; REQUIRED
  b.details[1].n_levels = 8 ; REQUIRED
  b.details[1].n_layers = 8 ; REQUIRED
  b.details[1].idl_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[1].dataMin = 0.0
  b.details[1].dataMax = 1900.0
  b.details[1].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 171
;
  b.details[2].measurement = '171'
  b.details[2].n_levels = 8
  b.details[2].n_layers = 8
  b.details[2].idl_bitdepth = 8
  b.details[2].bit_rate = [0.5,0.01]
  b.details[2].dataMin = 0.0
  b.details[2].dataMax = 3500.0
  b.details[2].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 193
;
  b.details[3].measurement = '193'
  b.details[3].n_levels = 8
  b.details[3].n_layers = 8
  b.details[3].idl_bitdepth = 8
  b.details[3].bit_rate = [0.5,0.01]
  b.details[3].dataMin = 0.0
  b.details[3].dataMax = 5500.0
  b.details[3].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 211
;
  b.details[4].measurement = '211'
  b.details[4].n_levels = 8
  b.details[4].n_layers = 8
  b.details[4].idl_bitdepth = 8
  b.details[4].bit_rate = [0.5,0.01]
  b.details[4].dataMin = 0.0
  b.details[4].dataMax = 3500.0
  b.details[4].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 304
;
  b.details[5].measurement = '304'; REQUIRED
  b.details[5].n_levels = 8 ; REQUIRED
  b.details[5].n_layers = 8 ; REQUIRED
  b.details[5].idl_bitdepth = 8 ; REQUIRED
  b.details[5].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[5].dataMin = 0.0
  b.details[5].dataMax = 3500.0
  b.details[5].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 335
;
  b.details[6].measurement = '335'; REQUIRED
  b.details[6].n_levels = 8 ; REQUIRED
  b.details[6].n_layers = 8 ; REQUIRED
  b.details[6].idl_bitdepth = 8 ; REQUIRED
  b.details[6].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[6].dataMin = 0.0
  b.details[6].dataMax = 3500.0
  b.details[6].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 1600
;
  b.details[7].measurement = '1600'; REQUIRED
  b.details[7].n_levels = 8 ; REQUIRED
  b.details[7].n_layers = 8 ; REQUIRED
  b.details[7].idl_bitdepth = 8 ; REQUIRED
  b.details[7].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[7].dataMin = 0.0
  b.details[7].dataMax = 800.0
  b.details[7].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 1700
;
  b.details[8].measurement = '1700'; REQUIRED
  b.details[8].n_levels = 8 ; REQUIRED
  b.details[8].n_layers = 8 ; REQUIRED
  b.details[8].idl_bitdepth = 8 ; REQUIRED
  b.details[8].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[8].dataMin = 0.0
  b.details[8].dataMax = 3500.0
  b.details[8].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10

;
; 4500
;
  b.details[9].measurement = '4500'; REQUIRED
  b.details[9].n_levels = 8 ; REQUIRED
  b.details[9].n_layers = 8 ; REQUIRED
  b.details[9].idl_bitdepth = 8 ; REQUIRED
  b.details[9].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[9].dataMin = 0.0
  b.details[9].dataMax = 38000.0
  b.details[9].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10

;
; Verify
;
  verify = { naxis1:  { default:4096, accept:{type:g.exact,value:[4096]} },$
             naxis2:  { default:4096, accept:{type:g.exact,value:[4096]} }}

  b = add_tag(b,verify,'verify')
  return,b
end 
