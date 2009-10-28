

nickname = 'ZAP-C'

;
; In here is the code you use to turn a FITS file into something
; usuable for science, or at worst, for a public image.  There should
; be two definite outputs, a SINGLE 2 dimensional array (img) and a
; SINGLE header file (header)
;

;
; Somewhere in the FITS header the observation time is defined.  The
; observation time consists of both the date and time
;

  obs_time = function_which_gets_observation_time_from_FITS_header(header)

;
; Somewhere in the FITS header the actual MEASUREMENT is defined.
; Sometimes we can just take it directly from the FITS file, for
; example, the EIT wavelength stored in the FITS header is also the
; MEASUREMENT.  Sometimes, however, this is not the case.  For
; example, LASCO data is accurately described by the polarizer and
; filter state, but very few people actually describe LASCO data using
; those states - it is much more common to refer to LASCO data simply
; by the term 'white light'.  Therefore, you may need to change the output of the
; FITS header to correspond to the commonly used terms
;



;
; Get the components of the observation date and time by parsing the
; OBS_TIME string. 
;
  yy = strmid(obs_time,0,4) ; year
  mm = strmid(obs_time,5,2) ; month
  dd = strmid(obs_time,8,2) ; day
  hh = strmid(obs_time,11,2) ; hours
  mmm = strmid(obs_time,14,2) ; minutes
  ss = strmid(obs_time,17,2) ; seconds
  milli = strmid(obs_time,20,3) ; milliseconds
;
; Get the observation and measurement details
;
  oidm = JI_HV_OIDM2(nickname)
  observatory = oidm.observatory
  instrument = oidm.instrument
  detector = oidm.detector
  measurement = oidm.measurement
;
; Add in the extra information 
;
  header = add_tag(header,observatory,'hv_observatory')
  header = add_tag(header,instrument,'hv_instrument')
  header = add_tag(header,detector,'hv_detector')
  header = add_tag(header,measurement,'hv_measurement')
  header = add_tag(header,0.0,'hv_rotation')
  header = add_tag(header,progname,'hv_source_program')

;
; HVS file
;
; img: image = single two dimensional array
; header: string
;
; observatory
; instrument
; detector
; measurement
;
  hvs = {img:img,header:header,$
         observatory:observatory,instrument:instrument,detector:detector,measurement:measurement,$
         yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli}
;
; Write a JP2
;
     JI_WRITE_LIST_JP2,hvs,rootdir
