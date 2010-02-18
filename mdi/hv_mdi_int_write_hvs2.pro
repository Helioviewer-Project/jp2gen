;
; 20 nov 2008
;
; nicked off of this web page
;
; 
;
FUNCTION HV_MDI_INT_WRITE_HVS2,infile,rootdir,details = details
  progname = 'HV_MDI_INT_WRITE_HVS2'
;
; get the observatory, instrument, detector names for MDI
;
  observatory = details.observatory
  instrument = details.instrument
  detector = details.detector
  measurement = 'continuum'
;
  observation =  observatory + '_' + instrument + '_' + detector + '_' + measurement
;
;  Read in the file and pertinent image header keywords. 
;

  data = rfits(infile,head=hd,/scale)
;  obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
  obs_time = strtrim(sxpar(hd, 'DATE_OBS'),2)
  pangle = sxpar(hd, 'P_ANGLE')
  radius = sxpar(hd,'R_SUN')
  x0 = sxpar(hd, 'X0')
  y0 = sxpar(hd, 'Y0')
;
; get the components of the observation time
; Occasionally the seconds are reported as '60' - we fix this also
;
  ss = strmid(obs_time,17,2)
  if (ss eq '60') THEN BEGIN
     obs_time = (HV_FIX_TIME(obs_time,/hvstring)).date_obs
  endif
  yy = strmid(obs_time,0,4)
  mm = strmid(obs_time,5,2)
  dd = strmid(obs_time,8,2)
  hh = strmid(obs_time,11,2)
  mmm = strmid(obs_time,14,2)
  ss = strmid(obs_time,17,2)
  milli = strmid(obs_time,20,3)
;
; Convert T_OBS into the required date format
;
  hv_date_obs = yy + '-' + mm + '-' + dd + 'T' + $
                hh + ':' + mmm +':' + ss + $
                '.' + milli + 'Z'
;
; Convert T_OBS into the file format time
;
;  obs_time = yy + '_' + mm + '_' + dd + '_' + hh + mmm + ss + '.' + milli
;
; Crop and rotate the image. 
;
  cropped = circle_mask(data, x0, y0, 'GE', radius, mask=0)
  rotated = rot(cropped, pangle, 1, x0, y0)
  scaled = bytscl(rotated, min=1000, max=14000)
;
; get the location of the Sun
;
  sun     = circle_mask(data, x0, y0, 'LT', radius, mask=0,/map)
  sun_index = where(sun eq 1) 
;
; shift the color table so zero may be reserved for transparency
;
  minval=1.0
  maxval=255.0
  min_in = min(scaled(sun_index),max = max_in)
  image_new = 0b * scaled
  image_new(sun_index) = byte( (scaled(sun_index) - min_in)/float(max_in-min_in)*(maxval-minval) + minval)
  loadct,0
  tvlct,r,g,b,/get
;
; change the header to a structure, and add HV tags
;
  hd = fitshead2struct(hd)
  hd = add_tag(hd,observatory,'hv_observatory')
  hd = add_tag(hd,instrument,'hv_instrument')
  hd = add_tag(hd,detector,'hv_detector')
  hd = add_tag(hd,measurement,'hv_measurement')
  hd = add_tag(hd,'wavelength','hv_measurement_type')
  hd = add_tag(hd,0.0,'hv_rotation')
  hd = add_tag(hd,progname,'hv_source_program')
;  hd = add_tag(hd,hv_date_obs,'hv_date_obs')
;  hd = add_tag(hd,1,'hv_opacity_group')
;  hd = add_tag(hd,hd.r_sun,'hv_original_rsun')
;  hd = add_tag(hd,hd.cdelt1,'hv_original_cdelt1')
;  hd = add_tag(hd,hd.cdelt2,'hv_original_cdelt2')
;  hd = add_tag(hd,hd.crpix1,'hv_original_crpix1')
;  hd = add_tag(hd,hd.crpix2,'hv_original_crpix2')
;  hd = add_tag(hd,hd.naxis1,'hv_original_naxis1')
;  hd = add_tag(hd,hd.naxis2,'hv_original_naxis2')
;  hd = add_tag(hd,1,'hv_centering')
;
; save
;
  hvs = {img:image_new, header:hd, details:details,$
         measurement:measurement,$
         yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli}
  HV_WRITE_LIST_JP2,hvs,rootdir
  outfile = 'read ' + infile + $
            ' ; wrote ' + rootdir + obs_time + '_' + observation  + $
            ' ; ' +HV_JP2GEN_CURRENT(/verbose) + $
            ' ; at ' + systime(0)

  return,outfile
end
