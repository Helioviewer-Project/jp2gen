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
  a = ADD_TAG(a,'SOHO','observatory') ; REQUIRED
  a = ADD_TAG(a,'EIT','instrument') ; REQUIRED
  a = ADD_TAG(a,'EIT','detector') ; REQUIRED
;
; Add the nickname
;
  a = ADD_TAG(a,'EIT','nickname') ; REQUIRED
;
; Add the FULL name of this file
;
  a = ADD_TAG(a,'hvs_default_EIT.pro','hvs_details_filename') ; REQUIRED
;
; Add the version number of this file
;
  a = ADD_TAG(a,'1.0','hvs_details_filename_version') ; REQUIRED
;
; 304
;
  a[0].measurement = '304'; REQUIRED
  a[0].n_levels = 8 ; REQUIRED
  a[0].n_layers = 8 ; REQUIRED
  a[0].idl_bitdepth = 8 ; REQUIRED
  a[0].bit_rate = [0.5,0.01] ; REQUIRED
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
