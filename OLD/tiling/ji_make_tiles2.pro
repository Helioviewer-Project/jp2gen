;
; Makes a whole bunch of tiles from a list
;
pro ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = format
;
; check input
;
if not(keyword_set(rewrite)) then begin
   rewrite = 0
endif

;
; ---------------- Magic Numbers ---------------------------------------------------
;
; The hierarchy of length-scales
;
arcsec_per_px_hierarchy = 2.63*2.0^(findgen(51)-10)
;
; size of one arcseond in kilometers
;
km_per_arcsec = 725.0d0

;
; Equatorial solar radius in kilometers
;
rsun = 695500.0d0

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

         s(0) = 18 ; measurement
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


   if (instrument eq 'EIT') then begin
      if (detector eq 'EIT') then begin
         zoom_base   = 10    ; minimum zoom level
         zoom_offset = 12    ; maximum zoom level
         nx_congrid = 1024   ; congrid the original image to this size
         ny_congrid = 1024
         nx_new = 1024       ; embed the congridded image in an image this size
         ny_new = 1024

         s(0) = 20 ; measurement
         s(1) = 3
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
         tmask = where(mask eq 1)
      endif
   endif
endif


;
; ---------------- Look at the input -----------------------------------------------
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
; ---------------------------------------------------------------------
;
;
; read in the list of files
;
list = JI_READ_TXT_LIST(source_images+'/' +source_list)
n = n_elements(list)

yy_old = ''
mm_old = ''
dd_old = ''
hh_old = ''


for i = 0L,n-1 do begin
;
; are we looking at a new time
;
   new_time_flag = 0
;
; get the next file on the list
;
   filename = list(i)
;
; find the physical measurement
;
   measurement = strmid(filename,s(0),s(1))
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
   ss = '00'

   print,measurement

;
; create the appropriate directory, and rewrite files if necessary
;

   if (yy ne yy_old) then begin
      spawn,'mkdir ' + outdir + '/' + yy 
      yy_old = yy
      new_time_flag = 1
   endif
   if (mm ne mm_old) then begin
      spawn,'mkdir ' + outdir + '/' + yy + '/' + mm
      mm_old = mm
      new_time_flag = 1
   endif
   if (dd ne dd_old) then begin
      spawn,'mkdir ' + outdir + '/' + yy + '/' + mm + '/' + dd 
      dd_old = dd
      new_time_flag = 1
   endif
   if (hh ne hh_old) then begin
      spawn,'mkdir ' + outdir + '/' + yy + '/' + mm + '/' + dd + '/' + hh
      hh_old = hh
      new_time_flag = 1
   endif

   time_stamp =  yy + '/' + mm + '/' + dd + '/' + hh

   if (new_time_flag eq 1) then begin
      spawn,'mkdir ' + outdir + '/' + time_stamp + '/' + mission
      spawn,'mkdir ' + outdir + '/' + time_stamp + '/' + mission + '/'  + instrument
      spawn,'mkdir ' + outdir + '/' + time_stamp + '/' + mission + '/'  + instrument + '/' + detector
      if (rewrite eq 1) then begin
         pathname = outdir + '/' + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement + '/*'
         print,'Deleting and rewriting tiles at ' + pathname
         spawn,'rm -f ' + pathname
      endif else begin
         spawn,'mkdir ' + outdir + '/' + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
      endelse
      datatype_stamp = observer + '/' + measurement
   endif else begin
      spawn,'mkdir ' + outdir + '/' + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
      datatype_stamp = observer + '/' + measurement
   endelse

;
;  Load in the image and rescale it to EIT range of zoom scales
;
   
   offset_new_x = nx_new/2 - nx_congrid/2
   offset_new_y = ny_new/2 - ny_congrid/2
   device,decomposed = 1
;   image_orig = read_image(source_images + '/' + filename,r,g,b)
   image_orig = read_image(source_images + '/' + filename,r,g,b)
   image_congrid = congrid(image_orig,3,nx_congrid,ny_congrid)
   image_new = bytarr(3,nx_new,ny_new)
   image_new(0,offset_new_x:offset_new_x + nx_congrid-1,offset_new_y:offset_new_y + ny_congrid-1) = image_congrid(0,*,*)
   image_new(1,offset_new_x:offset_new_x + nx_congrid-1,offset_new_y:offset_new_y + ny_congrid-1) = image_congrid(1,*,*)
   image_new(2,offset_new_x:offset_new_x + nx_congrid-1,offset_new_y:offset_new_y + ny_congrid-1) = image_congrid(2,*,*)
;
; Set one colour to be transparent
;
   transcol = 240
;
; use the LASCO C2 mask defined above
;
   if ((instrument eq 'LAS') and (detector eq '0C2')) then begin
      for j = 0, 2 do begin
         z = reform( image_new(j,*,*) )
         z = nint(230*float(z)/255.0)
         z(tmask) = transcol
         image_new(j,*,*) = z(*,*)
      endfor
   endif
;
; use the LASCO C3 mask defined above
;
   if ((instrument eq 'LAS') and (detector eq '0C3')) then begin
      for j = 0, 2 do begin
         z = reform( image_new(j,*,*) )
         z = nint(230*float(z)/255.0)
         z(tmask) = transcol
         image_new(j,*,*) = z(*,*)
      endfor
   endif
;
; write the image
;
   temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.jpg'
;   write_image,temp,'JPEG',image_new,r,g,b,quality = 100
;   temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.sav'
;   save,
    temp = 'temp_' + mission + '.' + instrument + '.' + detector + '.tiff'
    write_tiff,temp,image_new;,red=r,green=g,blue = b

;   stop
;
;  write the tiles
;
   sfinal = outdir + '/' + time_stamp + '/' + datatype_stamp
   tileroot = ji_txtrep(time_stamp + mmm + ss + '/' + datatype_stamp,'/','_') 
   print,sfinal
   print,tileroot
   ji_file2tiles_3,temp, out_dir = sfinal, stamp = tileroot,$
                 zoom_offset = zoom_offset,zoom_base = zoom_base,$
                 format = format,origin = ul_origin, scale = native_scale,fitype = fitype

endfor

return
end
