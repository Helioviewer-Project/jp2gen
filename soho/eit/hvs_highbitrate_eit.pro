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

FUNCTION HVS_HIGHBITRATE_EIT
;
; Get some general setup details.
;
  g = HVS_GEN()
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [8.0,0.01]}
;
; In this case, each EIT measurement requires the same type of details
;
  a = replicate( d , 4 )
;
; Full description
;
  b = {details:a,$  ; REQUIRED
       observatory:'SOHO',$ ; REQUIRED
       instrument:'EIT',$ ; REQUIRED
       detector:'EIT',$ ; REQUIRED
       nickname:'EIT',$ ; REQUIRED
       hvs_details_filename:'hvs_highbitrate_eit.pro',$ ; REQUIRED
       hvs_details_filename_version:'1.0'} ; REQUIRED
;
; 304
;
  b.details[0].measurement = '304'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [8.0,0.01] ; REQUIRED
;
; 171
;
  b.details[1].measurement = '171'
  b.details[1].n_levels = 8
  b.details[1].n_layers = 8
  b.details[1].idl_bitdepth = 8
  b.details[1].bit_rate = [8.0,0.01]

;
; 195
;
  b.details[2].measurement = '195'
  b.details[2].n_levels = 8
  b.details[2].n_layers = 8
  b.details[2].idl_bitdepth = 8
  b.details[2].bit_rate = [8.0,0.01]

;
; 284
;
  b.details[3].measurement = '284'
  b.details[3].n_levels = 8
  b.details[3].n_layers = 8
  b.details[3].idl_bitdepth = 8
  b.details[3].bit_rate = [8.0,0.01]
;
; Verify
;
  verify = { naxis1:  { default:1024, accept:{type:g.exact,value:[1024]} },$
             naxis2:  { default:1024, accept:{type:g.exact,value:[1024]} },$
             date_obs:{ default:g.na, accept:{type:g.exact,value:g.time} },$
             telescop:{ default:'SOHO', accept:{type:g.exact,value:['SOHO']} },$
             instrume:{ default:'EIT', accept:{type:g.exact,value:['EIT']} },$
             wavelnth:{ default:g.na, accept:{type:g.exact,value: [b.details[*].measurement]} },$
             crpix1:  { default:512, accept:{type:g.exact,value:[512]} },$
             crpix2:  { default:512, accept:{type:g.exact,value:[512]} },$
             cdelt1:  { default:2.63, accept:{type:g.range,value:[2.4,3.0]} },$
             cdelt2:  { default:2.63, accept:{type:g.range,value:[2.4,3.0]} },$
             solar_r: { default:369.88, accept:{type:g.range,value:[350.0,400.0]} }   }

  b = add_tag(b,verify,'verify')
  return,b
end 
