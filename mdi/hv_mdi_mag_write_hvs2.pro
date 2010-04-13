;
; 16 may 2008
;
; nicked off of this web page
;
; 
;
function HV_MDI_MAG_WRITE_HVS2,infile,rootdir,details = details
  progname = 'HV_MDI_MAG_WRITE_HVS2'

;
; get the observatory, instrument, detector names for MDI
;
  observatory = details.observatory
  instrument = details.instrument
  detector = details.detector
  measurement = 'magnetogram'
;
  observation =  observatory + '_' + instrument + '_' + detector + '_' + measurement

;
;  Read in the file and pertinent image header keywords. 
;  *****************************************************

  data = rfits(infile,head=hd,/scale)
  if tag_exist(fitshead2struct(hd),'DATE_OBS') then begin
     obs_time = strtrim(sxpar(hd, 'DATE_OBS'),2)
  endif else begin
     obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
  endelse
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
  if milli eq 'UT' then milli = '000' ; T_OBS doesn't have milliseconds
;
; Convert T_OBS into the required date format
;
  hv_date_obs = yy + '-' + mm + '-' + dd + 'T' + $
                hh + ':' + mmm +':' + ss + $
                '.' + milli + 'Z'
;
; Crop and rotate the image. 
;
  cropped = circle_mask(data, x0, y0, 'GE', radius, mask=0)
  rotated = rot(cropped, pangle, 1, x0, y0)
  scaled = bytscl(rotated, min=-1000, max=1000)
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
  hd = add_tag(hd,'longitudinal magnetic flux density','hv_measurement_type')
  hd = add_tag(hd,0.0,'hv_rotation')
  hd = add_tag(hd,progname,'hv_source_program')
;  hd = add_tag(hd,hd.date_obs,'hv_date_obs')
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
  hvs = {dir:'NotGiven',$
         fitsname:hd.datafile,$
         img:image_new, header:hd, details: details,$
         measurement:measurement,$
         yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli}
  HV_WRITE_LIST_JP2,hvs,jp2_filename = jp2_filename, already_written = already_written
  if not(already_written) then begin
     log_comment = 'read ' + infile + $
                   ' ; ' + HV_JP2GEN_CURRENT(/verbose) + $
                   ' ; at ' + systime(0)
     HV_LOG_WRITE,hvs,log_comment + ' ; wrote ' + jp2_filename
  endif else begin
     jp2_filename = 'already_written'
  endelse

  return,jp2_filename
end
