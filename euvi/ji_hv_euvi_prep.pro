;
; 24 August 2009
;
; ji_hv_euvi_prep
;
; Prep and write jp2 files from STEREO-EUVI data
;

FUNCTION JI_HV_EUVI_PREP,list,observer
;
; Load in the HVS observer details
;
  hvs_od = JI_OBSERVER_DETAILS(observer)
;
; HV - set the observation chain
;
  oidm = JI_HV_OIDM2(observer)
  observatory = oidm.observatory
  instrument = oidm.instrument
  detector = oidm.detector
;
; Storage location
;
  storage = JI_HV_STORAGE()
;
; Get the right list
;
  if observer eq 'EUVI-A' then begin
     list_sc = list.sc_a
     stereo = 'ahead'
  endif
  if observer eq 'EUVI-B' then begin
     list_sc = list.sc_b
     stereo = 'behind'
  endif
;
; Number of elements
;
  n = n_elements(list_sc)
;
; JP2 files written
;
  outfile = strarr(n)
;
; Go through the list
;
  for i = 0,n -1 do begin
;
; Run SECCHI_PREP
;
     JI_SSC_BROWSE_SECCHI_JPEG,list_sc[i],'',stereo,'/service',hv_answer

     img = hv_answer.temp
     header = hv_answer.header
;
; Get the wavelength
;
     measurement = trim(header.wavelnth)
;
; Update the FITS header with HV tags
;
     header = add_tag(header,observatory,'hv_observatory')
     header = add_tag(header,instrument,'hv_instrument')
     header = add_tag(header,detector,'hv_detector')
     header = add_tag(header,measurement,'hv_measurement')
     header = add_tag(header, header.date_obs,'hv_date_obs')
     header = add_tag(header, header.crota,'hv_rotation')
;
; HV - get the components to the observation time and date
;
     yy = strmid(header.date_obs,0,4)
     mm = strmid(header.date_obs,5,2)
     dd = strmid(header.date_obs,8,2)
     hh = strmid(header.date_obs,11,2)
     mmm = strmid(header.date_obs,14,2)
     ss = strmid(header.date_obs,17,2)
;
; create the hvs structure
;
     hvs = {img:img,$
            header:header,$
            observatory:observatory,instrument:instrument,detector:detector,measurement:measurement,$
            yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss}
;
; write the JP2 file
;
     JI_WRITE_LIST_JP2,hvs,storage.jp2_location, loc = loc,filename = filename
;
;
;
     outfile[i] = loc + filename + '.jp2'
  endfor
  return, outfile
end
