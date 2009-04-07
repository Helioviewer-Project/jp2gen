;
; 16 may 2008
;
; nicked off of this web page
;
; 
;
function ji_mdi_write_img,infile,outfile

;  Read in the file and pertinent image header keywords. 
;  *****************************************************

  data = rfits(infile,head=hd,/scale)
  obs_time = strtrim(sxpar(hd, 'T_OBS'),2)
  pangle = sxpar(hd, 'P_ANGLE')
  radius = sxpar(hd,'R_SUN')
  x0 = sxpar(hd, 'X0')
  y0 = sxpar(hd, 'Y0')

; Crop and rotate the image. 
;***************************
 
  cropped = circle_mask(data, x0, y0, 'GE', radius, mask=0)
  rotated = rot(cropped, pangle, 1, x0, y0)
  scaled = bytscl(rotated, min=1000, max=14000)

  loadct,0
  im2=bytarr(1024,1024,3)

  tvlct,r,g,b,/get                            
  im2[*,*,0]=r(scaled)    
  im2[*,*,1]=g(scaled)                          
  im2[*,*,2]=b(scaled)                                                                           
  WRITE_JPEG, + outfile + '.jpg', im2, true=3, quality=100, /progressive

end
