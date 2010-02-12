;
; Function which defines the EIT JP2 encoding parameters for each type
; of measurement
;

FUNCTION hvs_default_EIT
;
; Each measurement requires some details to control the creation of
; JP2 files
;
  details = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01]}
;
; In this case, each EIT measurement requires the same type of details
;
  a = replicate( details , 4 )
;
; Add the observatory, instrument, detector
;
  a = ADD_TAG(a,'SOHO','observatory')
  a = ADD_TAG(a,'EIT','instrument')
  a = ADD_TAG(a,'EIT','detector')
;
; Add the nickname
;
  a = ADD_TAG(a,'EIT','nickname')
;
; Add the FULL name of this file
;
  a = ADD_TAG(a,'hvs_default_EIT.pro','hvs_details_filename')
;
; Add the version number of this file
;
  a = ADD_TAG(a,'1.0','hvs_details_filename_version')
;
; 304
;
  a[0].measurement = '304'
  a[0].n_levels = 8
  a[0].n_layers = 8
  a[0].idl_bitdepth = 8
  a[0].bit_rate = [0.5,0.01]
;
; 171
;
  a[1].measurement = '171'
  a[1].n_levels = 8
  a[1].n_layers = 8
  a[1].idl_bitdepth = 8
  a[1].bit_rate = [0.5,0.01]

;
; 195
;
  a[2].measurement = '195'
  a[2].n_levels = 8
  a[2].n_layers = 8
  a[2].idl_bitdepth = 8
  a[2].bit_rate = [0.5,0.01]

;
; 284
;
  a[3].measurement = '284'
  a[3].n_levels = 8
  a[3].n_layers = 8
  a[3].idl_bitdepth = 8
  a[3].bit_rate = [0.5,0.01]

  return,a
end 
