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
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01]}
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
; 93
;
  b.details[0].measurement = '93'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 131
;
  b.details[0].measurement = '131'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 171
;
  b.details[1].measurement = '171'
  b.details[1].n_levels = 8
  b.details[1].n_layers = 8
  b.details[1].idl_bitdepth = 8
  b.details[1].bit_rate = [0.5,0.01]

;
; 193
;
  b.details[2].measurement = '193'
  b.details[2].n_levels = 8
  b.details[2].n_layers = 8
  b.details[2].idl_bitdepth = 8
  b.details[2].bit_rate = [0.5,0.01]

;
; 211
;
  b.details[3].measurement = '211'
  b.details[3].n_levels = 8
  b.details[3].n_layers = 8
  b.details[3].idl_bitdepth = 8
  b.details[3].bit_rate = [0.5,0.01]

;
; 304
;
  b.details[0].measurement = '304'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 335
;
  b.details[0].measurement = '335'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 1600
;
  b.details[0].measurement = '1600'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 1700
;
  b.details[0].measurement = '1700'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED

;
; 4500
;
  b.details[0].measurement = '4500'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED


;
; Verify
;
  verify = { naxis1:  { default:4096, accept:{type:g.exact,value:[4096]} },$
             naxis2:  { default:4096, accept:{type:g.exact,value:[4096]} }}

  b = add_tag(b,verify,'verify')
  return,b
end 
