;+
; write_jp2.pro
; write images in JPEG 2000 format, optionally include FITS header in
; XML format
; wrapper for IDLffJPEG2000 
;
; 2008-11-13 D. M., original 
;
; 2009-01-23 Extensive edits by JI to accept hvs.sav files
; 2009-01-29 JI, added 'institute' and 'contact' required variables
;            to create a comment with attribution and creation
;            information in the JP2 file.
; 2009-02-23 JI, implemented re-scaling of the images based on
;            contained in the FITS header as opposed to assuming
;            a fixed re-scaling for all files from a particular
;            observer.  Also implemented a minimal image embedding
;            when the data is written to JP2 file.
;
;
;-

PRO ji_write_jp2,file,image,bit_rate=bit_rate,n_layers=n_layers_jp2,n_levels=n_levels_jp2,fitsheader=fitsheader,_extra=_extra,head2struct=head2struct, $
                 institute, contact
;
; this program name
;
  progname = 'ji_write_jp2'
;
; Get the header information
;
  IF keyword_set(head2struct) THEN header = fitshead2struct(fitsheader) ELSE header = fitsheader
;
; ---------------- Magic Numbers ---------------------------------------------------
;
; Pixel size
; All images must be rescaled to a given hierarchy of pixel scales
; At the moment (Jan 2009) we are using the EIT native pixel size
; in arcseconds per pixel.  We expect to change this number to reflect
; the measured SDO pixel size.
;
; Size of one arcsecond in kilometers
;
;  km_per_arcsec = 725.0d0 ; kilometers per arcsecond
;
; The hierarchy of length-scales
;
;; arcsec_per_px_hierarchy = 2.63*2.0^(findgen(51)-20)
;; ;
;; ; size of one arcseond in kilometers
;; ;
;; km_per_arcsec = 725.0d0

;; ;
;; ; Equatorial solar radius in kilometers
;; ;
;; rsun = 695500.0d0

;
; Hierarchy Scales
;
; Equatorial solar radius in kilometers - constant for ALL observations
;
  km_per_rsun = 695500.0d0
;
; Arcseconds per pixel
;
  arcsec_per_pixel = 2.63
;
; Pixels per solar radius
;
  pixel_per_rsun = 371.480
;
; The fixed hierarchy of length-scales
;
  km_per_pixel = km_per_rsun / pixel_per_rsun
  km_per_pixel_hierarchy = km_per_pixel*2.0^(findgen(51)-20)
  arcsec_per_px_hierarchy = arcsec_per_pixel*2.0^(findgen(51)-20)
;
; The observed kilometers per pixel
;
  km_per_pixel_observed = km_per_rsun / header.hv_original_rsun
;
; Find which observation we are looking at
;
  observatory = header.hv_observatory
  instrument = header.hv_instrument
  detector = header.hv_detector
  measurement = header.hv_measurement
;
  observer = observatory + '/' + instrument + '/' + detector
;
; Supported observers, usually an observatory/instrument/detector
; triplet, and their properties
;
  supported = {observer:strarr(4)}
  supported.observer[0] = 'SOH/EIT/EIT'

  supported.observer[1] = 'SOH/MDI/MDI'

  supported.observer[2] = 'SOH/LAS/0C2'

  supported.observer[3] = 'SOH/LAS/0C3'

  if ( (where(observer eq supported.observer))[0] eq -1) then begin
     print,'Unsupported observer.  Stopping.'
     stop
  endif else begin
;
; set dafaults for JPEG2000 options
;
     IF KEYWORD_SET(bit_rate) eq 0 THEN bit_rate=[0.5,0.01]
     IF KEYWORD_SET(n_layers_jp2) eq 0 THEN n_layers_jp2=8
     IF KEYWORD_SET(n_levels_jp2) eq 0 THEN n_levels_jp2=8

;
; Magic numbers for each supported observer.
;
;;       if (observatory eq 'SOH') then begin
         
;;          if (instrument eq 'EIT') then begin
;;             if (detector eq 'EIT') then begin
;;                hv_xlen = 1024 ; congrid the original image to this size
;;                hv_ylen = 1024
;;                nx_embed = 2048    ; temporarily embed the congridded image in an image this size
;;                ny_embed = 2048
;;                zoom = 20
;;             endif
;;          endif
;;          if (instrument eq 'MDI') then begin
;;             if (detector eq 'MDI') then begin
;;                hv_xlen = 1575
;;                hv_ylen = 1575
;;                nx_embed = 2048    
;;                ny_embed = 2048
;;                zoom = 19
;;             endif
;;          endif
;;          if (instrument eq 'LAS') then begin
;;             if (detector eq '0C2') then begin
;;                hv_xlen = 1158
;;                hv_ylen = 1158
;;                nx_embed = 2048    
;;                ny_embed = 2048
;;                zoom = 22
;;             endif
;;             if (detector eq '0C3') then begin
;;                hv_xlen = 1363
;;                hv_ylen = 1363
;;                nx_embed = 2048    
;;                ny_embed = 2048
;;                zoom = 24
;;             endif
;;          endif
;;       endif
;
; Find the qualities of the embedding for the new image
;
     a = ji_hv_find_embed(km_per_pixel_hierarchy,$
                          km_per_pixel_observed,$
                          header.hv_original_naxis1,$
                          header.hv_original_naxis2)
     hv_xlen = a.hv_xlen
     hv_ylen = a.hv_ylen
     nx_embed = a.nx_embed
     ny_embed = a.ny_embed
     zoom = a.sc
;
; ---------------- CREATE THE NEW IMAGE -----------------------------------------------
;
;
; New pixel size
;
      xpx_new = arcsec_per_px_hierarchy(zoom)
      ypx_new = arcsec_per_px_hierarchy(zoom)
;
; Ratio of old pixel size to new
;
      ratio = header.cdelt1 / xpx_new
;
; Images which are supposed to have the centre of the Sun at the
; centre of the image have these offsets
;
      if (header.hv_centering eq 1) then begin
; For sun-centred images, the centre is at the middle of the full
; image
         hv_crpix1 = nx_embed/2
         hv_crpix2 = ny_embed/2

         hv_xcen = hv_crpix1
         hv_ycen = hv_crpix2
; The rescaled data is placed at the exact centre of the embedding
; larger image
         offset_new_x = hv_crpix1 - hv_xlen/2
         offset_new_y = hv_crpix2 - hv_ylen/2
; The centre of the original image was probably not pointed at the
; centre of the Sun.  Calculate this correction in units of the new
; pixel size 
         xr = (header.hv_original_crpix1 - header.hv_original_naxis1/2)*ratio
         yr = (header.hv_original_crpix2 - header.hv_original_naxis2/2)*ratio

; Calculate where the rescaled data should be placed in the larger
; embedding. 
         if (abs(header.hv_crota1) le 1.0) then begin
            x1 = -xr + offset_new_x
            x2 = -xr + offset_new_x + hv_xlen-1
            y1 = -yr + offset_new_y
            y2 = -yr + offset_new_y + hv_ylen-1
            hv_xdis = -xr
            hv_ydis = -yr
         endif else begin
            x1 = xr + offset_new_x
            x2 = xr + offset_new_x + hv_xlen-1
            y1 = yr + offset_new_y
            y2 = yr + offset_new_y + hv_ylen-1
            hv_xdis = xr
            hv_ydis = yr
         endelse
      endif
;
; Put the loaded image in appropriate place in the new image
;   
      image_congrid = congrid(image,hv_xlen,hv_ylen)
      image_new = bytarr(nx_embed,ny_embed)
;
; Set one colour to be transparent
;
      transcol = 0
;
; Recenter the image
;
      image_new(x1:x2,y1:y2) = image_congrid(*,*)
;
; Extract only the bit with data, plus a small border
;
      mlen = 1 + nint(max([abs(xr),abs(yr)]))
      image_new = image_new( nx_embed/2 - hv_xlen/2 - mlen:$
                             nx_embed/2 + hv_xlen/2 + mlen-1,$
                             ny_embed/2 - hv_ylen/2 - mlen:$
                             ny_embed/2 + hv_ylen/2 + mlen-1)
;
; Update
;     length of the embedding image
      nx_new = hv_xlen + 2*mlen
      ny_new = hv_ylen + 2*mlen
;     centre of the image
      hv_crpix1 = nx_new/2
      hv_crpix2 = ny_new/2
;     sun centre
      hv_xcen =  hv_crpix1
      hv_ycen =  hv_crpix2
;
; Apply any transparency masks as required
;
;      if have_tag(header,'mask') then begin
;         mask_congrid = congrid(mask,hv_xlen,hv_ylen)
;         mask_new = fltarr(nx_new,ny_new)
;         mask_new(x1:x2,y1:y2) = mask_congrid(*,*)
;         image_new( where(mask_new ne 0) ) = transcol
;      endif
;
; Bit rate re-adjustment factor
;
      bit_rate_factor = float(header.hv_original_naxis1)*float(header.hv_original_naxis2)/(float(hv_xlen)*float(hv_ylen))
;
; ********************************************************************************************************
;
; Create new HV XML tags to reflect the changes we have made.
;
; Centre of the data
      header = add_tag(header,hv_crpix1,'hv_crpix1')
      header = add_tag(header,hv_crpix2,'hv_crpix2')
; Extent of the non-zero portion of the embedded image
      header = add_tag(header,hv_xlen,'hv_xlen')
      header = add_tag(header,hv_ylen,'hv_ylen')
; Position of the centre of the image
      header = add_tag(header,hv_xcen,'hv_xcen')
      header = add_tag(header,hv_ycen,'hv_ycen')
; Full extent of the embedding image
      header = add_tag(header,nx_new,'hv_naxis1')
      header = add_tag(header,ny_new,'hv_naxis2')
; Size of the new pixels in arcseconds
      header = add_tag(header,xpx_new,'hv_cdelt1')
      header = add_tag(header,ypx_new,'hv_cdelt2')
; Add the displacement used to recenter the image
      header = add_tag(header,hv_xdis,'hv_xdis')
      header = add_tag(header,hv_ydis,'hv_ydis')
; Add in the maximum size of the embedding 
      header = add_tag(header,mlen,'hv_mlen')
; Size of the Sun in new pixels 
      header = add_tag(header,header.hv_original_rsun*ratio,'hv_rsun')
; Create and add an information string
      hv_comment = 'JP2 file created at ' + institute + $
                   ' using '+ progname + $
                   ' at ' + systime() + $
                   '. Contact ' + contact + $
                   ' for more details/questions/comments.'
      header = add_tag(header,hv_comment,'hv_comment')
;
; If the image is a coronograph then include the inner and outer radii
; of the coronagraph in image pixels
;
      if have_tag(header,'hv_rocc_inner') then begin
         header.hv_rocc_inner = header.hv_rocc_inner*header.hv_rsun
         header.hv_rocc_outer = header.hv_rocc_outer*header.hv_rsun
      endif
;
; ********************************************************************************************************
;
; Write the XML tags
;
;
;  FITS header into string in XML format:  
;
     xh = ''
; Line feed character:
     lf=string(10b)
;
     ntags = n_tags(header)
     tagnames = tag_names(header) 
     jcomm = where(tagnames eq 'COMMENT')
     jhist = where(tagnames eq 'HISTORY')
     jhv = where(strupcase(strmid(tagnames[*],0,3)) eq 'HV_')
     indf1=where(tagnames eq 'TIME_D$OBS',ni1)
     if ni1 eq 1 then tagnames[indf1]='TIME-OBS'
     indf2=where(tagnames eq 'DATE_D$OBS',ni2)
     if ni2 eq 1 then tagnames[indf2]='DATE-OBS'     
      xh='<?xml version="1.0" encoding="UTF-8"?>'+lf
;
; Enclose all the FITS keywords in their own container
; 
      xh+='<meta>'+lf
;
; FITS keywords
;
      xh+='<fits>'+lf
      for j=0,ntags-1 do begin
         if ( (where(j eq jcomm) eq -1) and (where(j eq jhist) eq -1) and (where(j eq jhv) eq -1) )  then begin      
;            xh+='<'+tagnames[j]+' descr="">'+strtrim(string(header.(j)),2)+'</'+tagnames[j]+'>'+lf
            xh+='<'+tagnames[j]+'>'+strtrim(string(header.(j)),2)+'</'+tagnames[j]+'>'+lf
         endif
      endfor
      xh+='</fits>'+lf
;
; Helioviewer XML tags
;
      xh+='<Helioviewer>'+lf
      for j=0,ntags-1 do begin
         if (where(j eq jhv) ne -1) then begin      
            reduced = strmid(tagnames[j],3,strlen(tagnames[j])-3)
            xh+='<'+reduced+'>'+strtrim(string(header.(j)),2)+'</'+reduced+'>'+lf
         endif
      endfor
      xh+='</Helioviewer>'+lf
;
; FITS history
;
      xh+='<history>'+lf
      j=jhist
      k=0
      while (header.(j))[k] ne '' do begin
         xh+=(header.(j))[k]+lf
         k=k+1
      endwhile
      xh+='</history>'+lf
;
; Comments
;
      xh+='<comment>'+lf
      j=jcomm
      k=0
      while (header.(j))[k] ne '' do begin
         xh+=(header.(j))[k]+lf
         k=k+1
      endwhile
      xh+='</comment>'+lf
;
; Enclose all the FITS keywords in their own container
;
      xh+='</meta>'+lf
;
; create JP2 file
; this is how it is done inside IDL.  Note that the current
; implementation of JPEG2000 in IDL 7.0 does not support alpha channel
; 
      oJP2 = OBJ_NEW('IDLffJPEG2000',file + '.jp2',/WRITE,$
                     bit_rate=bit_rate*bit_rate_factor,$
                     n_layers=n_layers_jp2,$
                     n_levels=n_levels_jp2,$
                     xml=xh)
      oJP2->SetData,image_new
      OBJ_DESTROY, oJP2
   endelse

END
