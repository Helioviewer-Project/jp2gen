;
; 16 may 2008
;
; nicked off of this web page
;
; 
;
function ji_mdi_mag_write_img2,infile,outfile,sav = sav
;
;
;
progname = 'ji_mdi_mag_write_img2'

;  Read in the file and pertinent image header keywords. 
;  *****************************************************

  data = rfits(infile,head=hd,/scale)
  obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
  pangle = sxpar(hd, 'P_ANGLE')
  radius = sxpar(hd,'R_SUN')
  x0 = sxpar(hd, 'X0')
  y0 = sxpar(hd, 'Y0')
  print,obs_time
  obs_time = strmid(obs_time,0,19)
  obs_time = ji_txtrep(obs_time,'.','_')
  obs_time = strmid(obs_time,0,13) + strmid(obs_time,14,2) + strmid(obs_time,17,2)

  obs_string = '_SOH_MDI_MDI_mag'

; Crop and rotate the image. 
;***************************

  imgmin = -1000
  cropped = circle_mask(data, x0, y0, 'GE', radius, mask = imgmin)
  rotated = rot(cropped, pangle, 1, x0, y0)
  scaled = bytscl(rotated, min = imgmin, max=1000)


  loadct,0
  tvlct,r,g,b,/get

  if keyword_set(sav) then begin
     outfile = outfile + obs_time + obs_string + '.sav'
     print,progname + ': Writing to ' + outfile
     hvs = {img:scaled, red:r, green:g, blue:b}
     save,filename = outfile, hvs
  endif else begin
     outfile = outfile + obs_time + obs_string + '.gif'
     print,progname + ': Writing to ' + outfile
     write_gif,outfile,scaled,r,g,b
  endelse

  return,1
end
