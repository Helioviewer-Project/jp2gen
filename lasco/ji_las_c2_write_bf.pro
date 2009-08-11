;
; Write the HVS file for a LASCO C2 image
;
; 2009-05-26.  Added error log file for data files with bad header information
;
;
FUNCTION JI_LAS_C2_WRITE_BF,filename,rootdir,write=write,bf_process = bf_process,standard_process = standard_process
;
;
;
  progname = 'JI_LAS_C2_WRITE_BF'
;
  oidm = ji_hv_oidm2('C2')
  observatory = oidm.observatory
  instrument = oidm.instrument
  detector = oidm.detector
  measurement = oidm.measurement
;
  observation =  observatory + '_' + instrument + '_' + detector + '_' + measurement
;
; prep the image using LASCO software, either the standard scaling or
; Bernhard Fleck's scaling
;
  IF ( keyword_set(standard_process) ) THEN BEGIN
     ld = JI_MAKE_IMAGE_C2(filename,/nologo,/nolabel)
  ENDIF
  IF ( keyword_set(bf_process) ) THEN BEGIN
     ld = JI_LAS_PROCESS_LIST_BF2(filename,rootdir,'c2')
  ENDIF
  IF ( NOT(keyword_set(standard_process)) and NOT(keyword_set(bf_process)) ) THEN BEGIN
     ld = JI_MAKE_IMAGE_C2(filename,/nologo,/nolabel)
  ENDIF
  

  return,outfile
end
