;
; Handle LASCO quicklook images
;
FUNCTION hv_lasco_handle_quicklook,image_new,hd,sunc
;
  progname = 'HV_LASCO_HANDLE_QUICKLOOK'
;
;
;
  rotate_by_this = get_soho_roll(hd.date_obs + ' ' + hd.time_obs)
  if (rotate_by_this ge 170.0) then begin
;     imtemp = image_new
;     sz = size(image_new,/dim)
;     image_new = 0.0*image_new
;     image_new = rotate(imtemp,2);

;     aa = sunc.xcen - sz[0]/2.0 ; difference between array centre and sun centre
;     bb = sunc.ycen - sz[1]/2.0 ; difference between array centre and sun centre
;     sunc.xcen = sz[0]/2.0 - aa ; sun centre appears to be in a different place
;     sunc.ycen = sz[1]/2.0 - bb ; 
;     hd.crpix1 = sunc.xcen
;     hd.crpix2 = sunc.ycen

     info_string = ' rotated by 180 degrees.'
  endif else begin
     info_string = '.'
  endelse
  print,progname + ': using quicklook FITS files' + info_string

  return,{image_new:image_new,sunc:sunc,hd:hd,rotate_by_this:rotate_by_this}
end
