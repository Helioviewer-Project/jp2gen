;
; 16 may 2008
;
; nicked off of this web page
;
; 
;
function JI_MDI_MAG_WRITE_IMG3,infile,rootdir
;
;
;
progname = 'JI_MDI_MAG_WRITE_IMG3'

;
observatory = 'SOH'
instrument = 'MDI'
detector = 'MDI'
measurement = 'mag'
;
observation =  observatory + '_' + instrument + '_' + detector + '_' + measurement

;
;  Read in the file and pertinent image header keywords. 
;  *****************************************************

  data = rfits(infile,head=hd,/scale)
  obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
  pangle = sxpar(hd, 'P_ANGLE')
  radius = sxpar(hd,'R_SUN')
  x0 = sxpar(hd, 'X0')
  y0 = sxpar(hd, 'Y0')
;
; get the components of the observation time
;
  yy = strmid(obs_time,0,4)
  mm = strmid(obs_time,5,2)
  dd = strmid(obs_time,8,2)
  hh = strmid(obs_time,11,2)
  mmm = strmid(obs_time,14,2)
  ss = strmid(obs_time,17,2)

  obs_time = yy + '_' + mm + '_' + dd + '_' + hh + mmm + ss
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
; save
;
  outfile = rootdir + obs_time + '_' + observation + '.hvs.sav'
  print,progname + ': Writing to ' + outfile
  hvs = {img:image_new, red:r, green:g, blue:b, header:hd,$
         observatory:observatory,instrument:instrument,detector:detector,measurement:measurement,$
         yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss}
  save,filename = outfile, hvs

  return,outfile
end
