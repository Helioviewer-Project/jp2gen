;
; Function which defines the AIA encoding parameters for each type
; of measurement
;
; Version 4.  Based on the scaling algorithm aia_fits2jpeg from 2011/01/03
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

FUNCTION HVS_VERSION6_AIA
;
; Get some general setup details.
;
  g = HVS_GEN()
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01],dataMin:0.0,dataMax:0.0,dataScalingType:0,dataExptime:0.0,gamma:1.0, fixedImageValue:[0,500000]}
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
       hvs_details_filename:'hvs_version5.pro',$ ; REQUIRED
       hvs_details_filename_version:'5.0',$ ; REQUIRED
       parent_out:'~/tmp/'}               ; REQUIRED
;
; Scaling algorithm
;
; get the image: A
; normalize the exposure: A/dataExptime = B
; clip: B>dataMin <dataMax = C
; byte scaling: BYTSCL(C) = D

;
; 94
;
  b.details[0].measurement = '94'; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[0].dataMin = 0.1;0.25;3.0
  b.details[0].dataMax = 30.0;250.0;50.0
  b.details[0].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[0].dataExptime = 1.0;4.99803
  b.details[0].gamma = 1.0
  b.details[0].fixedImageValue = [0,500000]
;
; 131
;
  b.details[1].measurement = '131'; REQUIRED
  b.details[1].n_levels = 8 ; REQUIRED
  b.details[1].n_layers = 8 ; REQUIRED
  b.details[1].idl_bitdepth = 8 ; REQUIRED
  b.details[1].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[1].dataMin = 0.7; 0.0
  b.details[1].dataMax = 500.0 ; 1900.0
  b.details[1].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[1].dataExptime = 1.0;6.99685
  b.details[1].gamma = 1.0;3.2
  b.details[1].fixedImageValue = [0,500000]
;
; 171
;
  b.details[2].measurement = '171'
  b.details[2].n_levels = 8
  b.details[2].n_layers = 8
  b.details[2].idl_bitdepth = 8
  b.details[2].bit_rate = [0.5,0.01]
  b.details[2].dataMin = 200.0
  b.details[2].dataMax = 14000.0
  b.details[2].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[2].dataExptime = 1.0;4.99803
  b.details[2].gamma = 1.0
  b.details[2].fixedImageValue = [0,500000]
;
; 193
;
  b.details[3].measurement = '193'
  b.details[3].n_levels = 8
  b.details[3].n_layers = 8
  b.details[3].idl_bitdepth = 8
  b.details[3].bit_rate = [0.5,0.01]
  b.details[3].dataMin = 20.0;1.0
  b.details[3].dataMax = 2500.0;8000.0
  b.details[3].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[3].dataExptime = 1.0;2.99950
  b.details[3].gamma = 1.0;4.0
  b.details[3].fixedImageValue = [0,500000]
;
; 211
;
  b.details[4].measurement = '211'
  b.details[4].n_levels = 8
  b.details[4].n_layers = 8
  b.details[4].idl_bitdepth = 8
  b.details[4].bit_rate = [0.5,0.01]
  b.details[4].dataMin = 7.0
  b.details[4].dataMax = 1500.0
  b.details[4].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[4].dataExptime = 1.0;4.99801
  b.details[4].gamma = 1.0;4.0
  b.details[4].fixedImageValue = [0,500000]
;
; 304
;
  b.details[5].measurement = '304'; REQUIRED
  b.details[5].n_levels = 8 ; REQUIRED
  b.details[5].n_layers = 8 ; REQUIRED
  b.details[5].idl_bitdepth = 8 ; REQUIRED
  b.details[5].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[5].dataMin = 0.8;0.0;60.0
  b.details[5].dataMax = 250.0;700;2000.0
  b.details[5].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[5].dataExptime = 1.0;4.99441
  b.details[5].gamma = 1.0
  b.details[5].fixedImageValue = [0,500000]

;
; 335
;
  b.details[6].measurement = '335'; REQUIRED
  b.details[6].n_levels = 8 ; REQUIRED
  b.details[6].n_layers = 8 ; REQUIRED
  b.details[6].idl_bitdepth = 8 ; REQUIRED
  b.details[6].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[6].dataMin = 0.4;0.25;8.0
  b.details[6].dataMax = 80.0;1000.0;1500.0
  b.details[6].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[6].dataExptime = 1.0;1.0;6.99734
  b.details[6].gamma = 1.0;1.8
  b.details[6].fixedImageValue = [0,500000]
;
; 1600
;
  b.details[7].measurement = '1600'; REQUIRED
  b.details[7].n_levels = 8 ; REQUIRED
  b.details[7].n_layers = 8 ; REQUIRED
  b.details[7].idl_bitdepth = 8 ; REQUIRED
  b.details[7].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[7].dataMin = 10.0;100.0
  b.details[7].dataMax = 400.0;625.0
  b.details[7].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[7].dataExptime = 1.0;2.99911
  b.details[7].gamma = 1.0
  b.details[7].fixedImageValue = [0,500000]
;
; 1700
;
  b.details[8].measurement = '1700'; REQUIRED
  b.details[8].n_levels = 8 ; REQUIRED
  b.details[8].n_layers = 8 ; REQUIRED
  b.details[8].idl_bitdepth = 8 ; REQUIRED
  b.details[8].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[8].dataMin = 220.0;100.0
  b.details[8].dataMax = 5000.0;2500.0
  b.details[8].dataScalingType = 1 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[8].dataExptime = 1.0;1.00026
  b.details[8].gamma = 1.0
  b.details[8].fixedImageValue = [0,500000]
;
; 4500
;
  b.details[9].measurement = '4500'; REQUIRED
  b.details[9].n_levels = 8 ; REQUIRED
  b.details[9].n_layers = 8 ; REQUIRED
  b.details[9].idl_bitdepth = 8 ; REQUIRED
  b.details[9].bit_rate = [0.5,0.01] ; REQUIRED
  b.details[9].dataMin = 4000.0;0.25
  b.details[9].dataMax = 20000.0;38000.0^2
  b.details[9].dataScalingType = 3 ; 0 - linear, 1 - sqrt, 3 - log10
  b.details[9].dataExptime = 1.0;1.00026
  b.details[9].gamma = 1.0
  b.details[9].fixedImageValue = [0,500000]
;
; Verify
;
  verify = { naxis1:  { default:4096, accept:{type:g.exact,value:[4096]} },$
             naxis2:  { default:4096, accept:{type:g.exact,value:[4096]} }}

  b = add_tag(b,verify,'verify')
  return,b
end 
