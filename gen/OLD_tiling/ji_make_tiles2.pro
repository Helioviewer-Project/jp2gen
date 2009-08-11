;
; Makes a whole bunch of tiles from a list
;
pro ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = format,timestamp = timestamp,jp2 = jp2
;
;
;
progname = 'ji_make_tiles2'
;
; check input
;
if not(keyword_set(rewrite)) then begin
   rewrite = 0
endif

;
; ---------------- Magic Numbers ---------------------------------------------------
;
; EIT pixel size
;
eit_pixel_size = 2.63
;
; The hierarchy of length-scales
;
arcsec_per_px_hierarchy = eit_pixel_size*2.0^(findgen(51)-10)
;
; size of one arcseond in kilometers
;
km_per_arcsec = 725.0d0

;
; Equatorial solar radius in kilometers
;
rsun = 695500.0d0

;
; Equatorial solar radius in arcseconds
;
rsun_arcsec = rsun/km_per_arcsec



;
; ---------------- Look at the input -----------------------------------------------
;
;
; The observing instrument
;
observer = mission + '/' + instrument + '/' + detector

;
; Select the data
;
s = intarr(20)                  ; string parsing data particular to this mission/instrument/detector

if (mission eq 'soho') then begin

   if (instrument eq 'EIT') then begin
      if (detector eq 'EIT') then begin
         zoom_base   = 10    ; minimum zoom level
         zoom_offset = 12    ; maximum zoom level
         nx_congrid = 1024   ; congrid the original image to this size
         ny_congrid = 1024
         nx_new = 1024       ; embed the congridded image in an image this size
         ny_new = 1024

         s(0) = 17 ; measurement
         s(1) = 3
         s(2) = 0 ; yy
         s(3) = 4
         s(4) = 4 ; mm
         s(5) = 2
         s(6) = 6 ; dd
         s(7) = 2
         s(8) = 9 ; hh
         s(9) = 2
         s(10) = 11 ; mmm
         s(11) = 2
      endif
   endif


   if (instrument eq 'MDI') then begin
      if (detector eq 'MDI') then begin
         zoom_base   = 9     ; minimum zoom level
         zoom_offset = 12    ; maximum zoom level
         nx_congrid = 1575   ; congrid the original image to this size
         ny_congrid = 1575
         nx_new = 2048       ; embed the congridded image in an image this size
         ny_new = 2048

         s(0) = 31 ; measurement
         s(1) = 3
         s(2) = 0 ; yy
         s(3) = 4
         s(4) = 5 ; mm
         s(5) = 2
         s(6) = 8 ; dd
         s(7) = 2
         s(8) = 11 ; hh
         s(9) = 2
         s(10) = 13 ; mmm
         s(11) = 2
         s(12) = 15 ; sss
         s(13) = 2
      endif
   endif
   if (instrument eq 'LAS') then begin
      if (detector eq '0C2') then begin
         zoom_base   = 12     ; minimum zoom level
         zoom_offset = 15    ; maximum zoom level
         nx_congrid = 1158   ; congrid the original image to this size
         ny_congrid = 1158
         nx_new = 2048       ; embed the congridded image in an image this size
         ny_new = 2048

         s(0) = 4 ; measurement
         s(1) = 3
         s(2) = 0 ; yy
         s(3) = 4
         s(4) = 4 ; mm
         s(5) = 2
         s(6) = 6 ; dd
         s(7) = 2
         s(8) = 9 ; hh
         s(9) = 2
         s(10) = 11 ; mmm
         s(11) = 2


         ;
         ; transparency mask
         ;
         mask = intarr(nx_new,ny_new)
         xcen = nx_new/2
         ycen = ny_new/2
         r1 = 1.50*rsun/km_per_arcsec/arcsec_per_px_hierarchy(zoom_base)
         r2 = 6.0*rsun/km_per_arcsec/arcsec_per_px_hierarchy(zoom_base)
         for i = 0,nx_new-1 do begin
            for j = 0,ny_new-1 do begin
               test_radius = sqrt( (float(i-xcen))^2 + (float(j-ycen))^2 )
               if (test_radius le r1) then begin
                  mask(i,j) = 1
               endif
               if (test_radius ge r2) then begin
                  mask(i,j) = 1
               endif
            endfor
         endfor
         if keyword_set(timestamp) then begin
            mask(400:700,400:500) = 0                     ; hack - remove
         endif
         tmask = where(mask eq 1)

      endif

      if (detector eq '0C3') then begin
         zoom_base   = 14     ; minimum zoom level
         zoom_offset = 17    ; maximum zoom level
         nx_congrid = 1363   ; congrid the original image to this size
         ny_congrid = 1363
         nx_new = 2048       ; embed the congridded image in an image this size
         ny_new = 2048

         s(0) = 4 ; measurement
         s(1) = 3
         s(2) = 0 ; yy
         s(3) = 4
         s(4) = 4 ; mm
         s(5) = 2
         s(6) = 6 ; dd
         s(7) = 2
         s(8) = 9 ; hh
         s(9) = 2
         s(10) = 11 ; mmm
         s(11) = 2
         ;
         ; transparency mask
         ;
         mask = intarr(nx_new,ny_new)
         xcen = nx_new/2
         ycen = ny_new/2
         r1 = 6.00*rsun/km_per_arcsec/arcsec_per_px_hierarchy(zoom_base)
         r2 = 30.0*rsun/km_per_arcsec/arcsec_per_px_hierarchy(zoom_base)
         for i = 0,nx_new-1 do begin
            for j = 0,ny_new-1 do begin
               test_radius = sqrt( (float(i-xcen))^2 + (float(j-ycen))^2 )
               if (test_radius le r1) then begin
                  mask(i,j) = 1
               endif
               if (test_radius ge r2) then begin
                  mask(i,j) = 1
               endif
            endfor
         endfor
         if keyword_set(timestamp) then begin
            mask(300:700,300:400) = 0             ; hack - remove
         endif
         tmask = where(mask eq 1)
      endif
   endif
endif

if (mission eq 'trac') then begin
   if (instrument eq 'TRA') then begin
      if (detector eq 'TRA') then begin
         v = intarr(12)      ; TRACE description of the image
         s = intarr(14)

         nx_congrid = 1024   ; congrid the original image to this size
         ny_congrid = 1024
         nx_new = 1024       ; embed the congridded image in an image this size
         ny_new = 1024

         s(0) = 27 ; measurement
         s(1) = 4
         s(2) = 3 ; yy
         s(3) = 4
         s(4) = 7 ; mm
         s(5) = 2
         s(6) = 9 ; dd
         s(7) = 2
         s(8) = 12 ; hh
         s(9) = 2
         s(10) = 14 ; mmm
         s(11) = 2
         s(12) = 16 ; mmm
         s(13) = 2

         v(0) = 34 ; no. pixels in the x direction
         v(1) = 4
         v(2) = 41 ; no. pixels in the y direction
         v(3) = 4
         v(4) = 47 ; centre position: x value
         v(5) = 7
         v(6) = 56 ; centre position: y value
         v(7) = 7
         v(8) = 68 ; arcsec per pixel in the x direction
         v(9) = 4
         v(10) = 77 ; arcsec per pixel in the y direction
         v(11) = 4

      endif
   endif
endif

;
; ---------------------------------------------------------------------
;
;
; read in the list of files
;
list = JI_READ_TXT_LIST(source_list)
n = n_elements(list)
trim_n = trim(n)

;
; old values of time used to detect new values
;
yy_old = ''
mm_old = ''
dd_old = ''
hh_old = ''

;
; main loop
;
for i = 0L,n-1 do begin
;
; are we looking at a new time
;
   new_time_flag = 0
;
; get the next file on the list
;
   filename = list(i)
   print,' '
   print,progname + ': processing # ' + trim(i) + ' out of ' + trim_n
   print,progname + ': Reading image '+ source_images + filename
;
; find the physical measurement
;
   measurement = strmid( trim(strmid(filename,s(0),s(1))),0,3)
   if (strlen(measurement) eq 2) then begin
      measurement = '0' + measurement 
   endif
;
; find the physical measurement - special cases
;
   if (observer eq 'soho/LAS/0C3') then begin
      measurement = '0WL'
   endif
   if (observer eq 'soho/LAS/0C2') then begin
      measurement = '0WL'
   endif
;
; observation time information
;
   yy = strmid(filename,s(2),s(3))
   mm = strmid(filename,s(4),s(5))
   dd = strmid(filename,s(6),s(7))
   hh = strmid(filename,s(8),s(9))
   mmm = strmid(filename,s(10),s(11))
   if (observer eq 'trac/TRA/TRA') then begin
      ss = strmid(filename,s(12),s(13))
   endif else begin
      ss = '00'
   endelse
;
; create the appropriate directory, and rewrite files if necessary
;

   if (yy ne yy_old) then begin
      spawn,'mkdir ' + outdir + yy 
      yy_old = yy
      new_time_flag = 1
   endif
   if (mm ne mm_old) then begin
      spawn,'mkdir ' + outdir + yy + '/' + mm
      mm_old = mm
      new_time_flag = 1
   endif
   if (dd ne dd_old) then begin
      spawn,'mkdir ' + outdir + yy + '/' + mm + '/' + dd 
      dd_old = dd
      new_time_flag = 1
   endif
   if (hh ne hh_old) then begin
      spawn,'mkdir ' + outdir + yy + '/' + mm + '/' + dd + '/' + hh
      hh_old = hh
      new_time_flag = 1
   endif

   time_stamp =  yy + '/' + mm + '/' + dd + '/' + hh

   if (new_time_flag eq 1) then begin
      spawn,'mkdir ' + outdir + time_stamp + '/' + mission
      spawn,'mkdir ' + outdir + time_stamp + '/' + mission + '/'  + instrument
      spawn,'mkdir ' + outdir + time_stamp + '/' + mission + '/'  + instrument + '/' + detector
      if (rewrite eq 1) then begin
         pathname = outdir + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement + '/*'
         print,progname + ': Deleting and rewriting tiles at ' + pathname
         spawn,'rm -f ' + pathname
      endif else begin
         spawn,'mkdir ' + outdir + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
      endelse
      datatype_stamp = observer + '/' + measurement
   endif else begin
      spawn,'mkdir ' + outdir + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
      datatype_stamp = observer + '/' + measurement
   endelse

;
;  Load in the image and rescale it to EIT range of zoom scales

;
;  For source images of the form .gif
;
   device,decomposed = 1
   image_orig = read_image(source_images + filename,red,green,blue)

;
;  For source images of the form .sav
;  The .sav file must contain the variables b0,red,green,blue
;
;   restore,source_images + filename
;   image_orig = b0
;
;  calculate image offsets, etc
;
;  SPECIAL CASE: TRACE
;  TRACE images come in a variety of image sizes and pixel scale
;  sizes.  The offsets and new congrid sizes have to be calculated on a case by case basis
;
; 
   if (observer eq 'trac/TRA/TRA') then begin
      trace_pixel_size = float(strmid(filename,v(8),v(9)))
      trace_nx = nint(strmid(filename,v(0),v(1)))
      trace_ny = nint(strmid(filename,v(2),v(3)))
      xcen = nint(strmid(filename,v(4),v(5)))
      ycen = nint(strmid(filename,v(6),v(7)))
;
;  calculate the zoom_base - this is the most zoomed in view of the
;                            data, and we are calculating the zoom
;                            level it exists at
;
      pixel_size_ratio = trace_pixel_size / eit_pixel_size
      z1 = -10
      repeat begin
         z1 = z1 + 1
      endrep until( (2.0^z1 le pixel_size_ratio) and (pixel_size_ratio le 2.0^(z1+1)) )
      zoom_base = 10 + z1
;
;  calculate the zoom_offset
;
      zoom_offset = zoom_base -1
      repeat begin
         zoom_offset = zoom_offset + 1
      endrep until( rsun_arcsec/arcsec_per_px_hierarchy(zoom_offset) le 256.0)
      zoom_offset = zoom_offset + 1
;
;  calculate the rescale
;
      frescale = trace_pixel_size / eit_pixel_size / (2.0^z1)
;
;  calculate the congrid size.  congrid the existing TRACE data to
;  this size
;
      nx_congrid = nint(frescale*trace_nx)
      ny_congrid = nint(frescale*trace_ny)
;
;  the size of the array in which the TRACE data exists at the highest
;  zoom level
;
      nx_new = 2^(10-zoom_base)*1024
      ny_new = 2^(10-zoom_base)*1024
;
;  bottom left cornor of the data in arcseconds
;
      x0 = xcen - trace_pixel_size*trace_nx / 2.0
      y0 = ycen - trace_pixel_size*trace_ny / 2.0
;
;  calculate the offsets for the bottom left hand corner of the TRACE
;  data given the original pointing of the data, and assuming sun
;  center is in the middle of the array (nx_new,ny_new)
;
      offset_new_x = nint( x0/arcsec_per_px_hierarchy(zoom_base) + nx_new/2 )
      offset_new_y = nint( y0/arcsec_per_px_hierarchy(zoom_base) + ny_new/2 )
   endif

   if ((observer eq 'soho/LAS/0C2') or $
       (observer eq 'soho/LAS/0C3') or $
       (observer eq 'soho/EIT/EIT') or $
       (observer eq 'soho/MDI/MDI') ) then begin
      offset_new_x = nx_new/2 - nx_congrid/2
      offset_new_y = ny_new/2 - ny_congrid/2
   endif

;
; ---------------- UNITS and SIZES -----------------------------------------------
;
;
; number of arcseconds per pixel for these images at the zoom_base
;
;
   arcsec_per_px = [arcsec_per_px_hierarchy(zoom_base),arcsec_per_px_hierarchy(zoom_base)]
;
; position of the centre of the Sun in the image in pixels.  In
; general, this should be taken from the FITS files
;
   sun_cen_px = [nx_new/2.0d0,ny_new/2.0d0]

;
; calculate the native scale and the position of the upper lefthand
; corner of the image when the sun centre is (0.0)
;
   native_scale = km_per_arcsec * arcsec_per_px /rsun
   ul_origin = km_per_arcsec * arcsec_per_px * ( [0.0,double(ny_new)] - sun_cen_px ) /rsun


;
; ---------------- CREATE THE NEW IMAGE -----------------------------------------------
;
;
; put the loaded image in appropriate place in the new image
;   
   image_congrid = congrid(image_orig,nx_congrid,ny_congrid)
   image_new = bytarr(nx_new,ny_new)
   image_new(offset_new_x:offset_new_x + nx_congrid-1,offset_new_y:offset_new_y + ny_congrid-1) = image_congrid(*,*)
;
; Set one colour to be transparent
;
   transcol = 0
;
; rescale the input image so that the
;
   minval=1.0
   maxval=255.0
   min_in = min(image_new,max = max_in)
;
; scale image values to range [minval,maxval] 
;
; WARNING - for trace images, no color rescaling is done
;
  if ((observer eq 'soho/LAS/0C2') or $
       (observer eq 'soho/LAS/0C3') or $
       (observer eq 'soho/EIT/EIT') or $
       (observer eq 'soho/MDI/MDI') ) then begin
     image_new = byte( (image_new - min_in)/float(max_in-min_in)*(maxval-minval) + minval)
  endif

;
;
; SPECIAL CASE: use the LASCO C2/C3 mask defined above
;
;
   if ((instrument eq 'LAS') and ( (detector eq '0C2') or (detector eq '0C3') )) then begin
         image_new(tmask) = transcol
   endif

;
; write the image
;
;   temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.jpg'
;   write_image,temp,'JPEG',image_new,r,g,b,quality = 100
;   temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.sav'
;   save,
;    temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.tiff'
;    write_tiff,temp,image_new;,red=r,green=g,blue = b
    temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.png'
    write_png,temp,image_new, red, green , blue,transparent = [transcol]

;
;  write the tiles
;
;    print,'* ', zoom_base,zoom_offset
   sfinal = outdir + time_stamp + '/' + datatype_stamp
   tileroot = ji_txtrep(time_stamp + mmm + ss + '/' + datatype_stamp,'/','_') 
   print,progname + ': tiles written to '+sfinal
   print,progname + ': tile rootname    '+tileroot
   ji_file2tiles_3,temp, out_dir = sfinal, stamp = tileroot,$
                 zoom_offset = zoom_offset,zoom_base = zoom_base,$
                 format = format,origin = ul_origin, scale = native_scale,fitype = fitype
;
;  write the jp2 files, if required
;
   if keyword_set(jp2) then begin


      ji_write_jp2, image_new, red, green, blue, observer, measurement, out_dir = sfinal, stamp = tileroot
   endif

endfor

return
end
