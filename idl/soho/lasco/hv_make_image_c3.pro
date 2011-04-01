
FUNCTION HV_MAKE_IMAGE_C3, img, hdr, FIXGAPS=fixgaps, VIDEOIMG=videoimg, PICT=pict, NOLABEL=nolabel, $
	NOLOGO=nologo, BKG=bkg, RDIFF=rdiff

; Keywords:
; FIXGAPS	Set to use previous image to replace missing data
; VIDEOIMG	Set to a variable which will contain television-ready image
; NOLABEL	Do not put time stamp or logo on images
;  NOLOGO	Put time stamp but not logo
;  PICT		Do not add LASCO logo to video-format image
;  BKG		Set to background image to use in place of GETBKGIMG; it should be
;		normalized to exposure time and properly sized
;
;
; Modified	10/23/98  N B Rich	change model_any_year to 0
;		12/07/98  N B Rich	change model_any_year from 1 to 0
;		03/10/99  N B Rich	change bmin, bmax to base on median of a box
;		03/09/99  N B Rich	change model_any_year from 0 to 1
; 1999/05/17	N B Rich	Add FIXGAPS keyword, common block
; 1999/05/25	N B Rich	Set fillcol
; 1999/06/11	N B Rich	Fix auto min/max
; 1999/06/21	N B Rich	Add 4 to bias
; 1999/08/25	N B Rich	Add dbias to bias; Normalize image and box_ref to exposure time
; 1999/09/21	N B Rich	Change dbias; use SOLAR_EPHEM instead of GET_SOLAR_RADIUS
; 1999/10/29	N B Rich	Add C3_BLOCK common block for masking pylon
; 2000/05	NB Rich		Add VIDEOIMG, PICT options
; 2000/06	NB Rich	- Compute dbias from pylon data
; 2000/10	NB Rich - Use NRL_LIB, not ANCIL_DATA
;  5/22/01	NB RIch - Add NOLABEL keyword
;  7/17/01	NB Rich - Use different mask for pylon than for pylonim; extend C3_BLOCK common block
; 11/20/01	NB Rich - Add BKG keyword
;  9/17/02	NB Rich - Add NOLOGO; change mask color
;  030127	jake	- made mods to allow for 512 images to be created
;			- moved image size and box stuff after background
;			- added FULL=1024 to calls to GET_SUN_CENTER, GET_SEC_PIXEL
;			- added /FFV to GETBKGIMG call
;			- put BIASing into REDUCE_STD_SIZE
;  030417 jake - made NOLABEL actually not put timestamp on
;	030717	jake	accounting for roll
;	030721	jake	moved roll checking for model to getbkgimg
;  2003.12.22, nbr - add RDIFF keyword; move FIXGAPS before ratio
;  Jan17,2008 -- Karl Battams -- switch to z-buffer instead of pixmaps -- much better for Linux
;
;
; 01/17/08 @(#)make_image_c3.pro	1.19 :LASCO IDL LIBRARY

;
COMMON RTMVI_COMMON_IMG, prev2,prev3,prev195,prev171,prev284,prev304,box_avg_prev2,box_avg_prev3,prev3_exptime
COMMON C3_BLOCK, pylonim, ctr, pylon

      ;IF hdr.exptime LT 15 THEN dbias = -7 ELSE dbias=-44	;**NBR,9/1/99
	dbias=0			;**NBR, 27 Jan 2000

      model_all=0
      model_any_year=0		; ** set 3/15/99, NBR
      LOADCT, 1
      GAMMA_CT, 0.6
      r_occ = 4.4
      r_occ_out = 31.5		;** set 12/7/99, NBR
      fillcol=80	;110	;128	; ** set 7/17/02, nbr
      dmin=-100
      dmax=100

      mdn = median(img)
	help,mdn

;	IF (hdr.lebxsum)^2 + (hdr.sumcol)^2 GT 2 THEN img = REDUCE_STD_SIZE(img,hdr,/FULL)
	img = REDUCE_STD_SIZE(img,hdr,/FULL, /BIAS)		;JAKE 030127-removed IF added /BIAS
	ind00=where(img LE 0)
      timestamp = STRMID(hdr.date_obs + ' ' + hdr.time_obs, 0, 16)

      IF datatype(pylonim) EQ 'UND' THEN BEGIN
	maskdir=GETENV('NRL_LIB')+'/lasco/data/calib/'
	print,'Reading ',maskdir+'c3clearmask2.fts'
	pylonim=readfits(maskdir+'c3clearmask2.fts')
	pylonima = readfits(maskdir+'c3clearmask2a.fts')
      	pylon=where(pylonima EQ 3)
      ENDIF

	IF keyword_set(BKG) THEN BEGIN
		imgm =  bkg
		mhdr = hdr
	ENDIF ELSE BEGIN

		imgm = GETBKGIMG(hdr, mhdr, ALL=model_all, ANY_YEAR=model_any_year, /ffv);	JAKE ADDED /FFV 030127
		imgm = imgm/mhdr.exptime
	ENDELSE

	;--Jake 030127
	;--moved these lines about img and boxes here from beginning
	;--to get the img of the resized img
	sz = SIZE(img)
	hsize = sz(1)
	vsize = sz(2)
	bx1 = (hsize)/2-100		;bx1 = 0
	bx2 = bx1+199			;bx2 = 1023
	by1 = vsize-30			;by1 = 0
	by2 = vsize-1			;by2 = 1023
	box=[bx1,bx2,by1,by2]
	box_ref=700.			;box_ref=1600
	print,"box:",box


      ;imgm = imgm/mhdr.exptime
      ;bias = OFFSET_BIAS(hdr, /SUM) + dbias	; NBR, 8/30/99		;JAKE-030127-done in reduce_std_size
      ;cimg = FLOAT(img) - bias	;subtract detector bias from image	;JAKE-030127-done in reduce_std_size
	cimg = FLOAT(img)						;JAKE-030127

      goodpyl = WHERE(cimg(pylon) GT 0)
      
	;** NBR, 11/1/99 --
	cimg = cimg/hdr.exptime
	box_ref=box_ref/mhdr.exptime
	;**
      IF goodpyl(0) NE -1 THEN BEGIN
      	;refmed = median(imgm(pylon(goodpyl)))
      	;imajemed=median(cimg(pylon(goodpyl)))
      	;dbias = imajemed-refmed-1
	pylondiff=cimg[pylon[goodpyl]] - imgm[pylon[goodpyl]]
	dbias= median(pylondiff)
      	help,dbias

      	cimg = cimg-dbias
      ENDIF
;window,2
;plot,cimg[*,300]-imgm[*,300],xrang=[200,400]

      box_img = DOUBLE(cimg(box(0):box(1),box(2):box(3)))
      box_imgr = DOUBLE(img(box(0):box(1),box(2):box(3)))
      good = WHERE(box_imgr GT 0)
      IF (good(0) GE 0) THEN BEGIN
         box_avg=TOTAL(box_img(good))/N_ELEMENTS(good) 
         box_avgr=TOTAL(box_imgr(good))/N_ELEMENTS(good) 
      ENDIF ELSE BEGIN
         good = where (cimg GT 0,n)
         box_avg=TOTAL(cimg(good))/n
         box_avgr=TOTAL(img(good))/n
      ENDELSE 
      print,'^^^^^^^^^^^^^^^^^^^^^^^^^'
      print,box_avg,box_avgr, hdr.exptime,mhdr.exptime
      cimg = TEMPORARY(cimg) * (box_ref/box_avg)        ;** normalize to counts in box
      help,box_ref,box_avg

      nonzero = WHERE(imgm NE 0)
      
      IF KEYWORD_SET(FIXGAPS) THEN BEGIN
         IF (ind00(0) NE -1) THEN BEGIN			;** gaps in this image
            IF (fixgaps EQ 1) or DATATYPE(prev3) EQ 'UND' THEN cimg(ind00) = fillcol $
            ELSE BEGIN
               cimg(ind00) = prev3(ind00);*box_avg_prev3/box_avg;	* (hdr.exptime/prev3_exptime);** fill gaps in this img with prev image with the correct scale
               print,'*********************************'
               print, box_avg_prev3/box_avg
            ENDELSE
         ENDIF
      ENDIF
        ;WINDOW, XSIZE=1024, YSIZE=1024, /FREE, /PIXMAP
	set_plot,'z'
        device,set_resolution=[hsize,vsize] 
        IF datatype(prev3) NE 'UND' THEN BEGIN
		IF ( hdr.crota1 eq 180. ) THEN rdiff = rotate(cimg-prev3,2) ELSE rdiff = cimg - prev3
		tvscl, rdiff<dmax>dmin
		RTMVIXY, timestamp
		rdiff = tvrd()
             ENDIF
	prev3 = cimg
        box_avg_prev3 = box_avg
        prev3_exptime = hdr.exptime

      cimg(nonzero) = TEMPORARY(cimg(nonzero)) / imgm(nonzero)   ;take ratio of image to model
;

      mbox = cimg(bx1-100:bx2+100,by1-300:by2)
      ;mbox = cimg(bx1:bx2,by1:by2)
      nz = where(mbox GT 0)
      IF nz(0) GE 0 THEN m = median(mbox(nz)) ELSE BEGIN
	 nz = where(cimg GT 0)
	 m = median(cimg(nz))
	 print,'Using whole image for m'
      ENDELSE			;** NBR, 6/21/99
help,m
      bmin = m-0.1
      bmax = m+0.15
	;print,bmin,bmax
				;** NBR, 10/29/99
      pylgtm = where(cimg GT 1.03*m and pylonim EQ 3)    ; NBR, set Jan 2000
      IF pylgtm(0) NE -1 THEN cimg(pylgtm)=m		

      TVLCT, r, g, b, /GET
;stop
      cimg = BYTSCL(cimg, bmin, bmax)
	nz = where(cimg GT 0)
	;fillcol=median(cimg(nz))

      sunc = GET_SUN_CENTER(hdr, /NOCHECK, FULL=1024); JAKE ADDED /FULL 030127
      arcs = GET_SEC_PIXEL(hdr, FULL=1024); JAKE ADDED /FULL 030127
      ;asolr = GET_SOLAR_RADIUS(hdr)
	yymmdd=UTC2YYMMDD(STR2UTC(hdr.date_obs+' '+hdr.time_obs))
	solar_ephem,yymmdd,radius=radius,/soho
	asolr = radius*3600
      r_sun = asolr/arcs

      ;** draw mask

      tmp_img = cimg & tmp_img(*) = 0 & TV,tmp_img
      HV_TVCIRCLE, r_occ_out*r_sun,sunc.xcen,sunc.ycen, /FILL, COLOR=1
      tmp_img = TVRD()
      ind1 = WHERE(tmp_img NE 1)
      IF (ind1(0) NE -1) THEN cimg(ind1) = fillcol
 
      cimg(0:2,*)		= fillcol	; add border
      cimg(vsize-3:vsize-1,*)	= fillcol
      cimg(*,0:2)		= fillcol
      cimg(*,hsize-3:hsize-1)	= fillcol

      TV, cimg

      HV_TVCIRCLE, r_occ*r_sun, sunc.xcen, sunc.ycen, /FILL, COLOR=fillcol

      ;** draw limb
      HV_TVCIRCLE, r_sun, sunc.xcen, sunc.ycen, COLOR=255, THICK=4

	IF ( hdr.crota1 eq 180. ) THEN BEGIN	;       jake 030717
		print, "Rotating image."			;       jake 030717
		cimg = ROTATE ( TVRD(), 2 )			;       jake 030717
		TV, cimg							;       jake 030717
	ENDIF									;       jake 030717

      IF NOT(KEYWORD_SET(NOLABEL)) THEN RTMVIXY, timestamp
      cimg = TVRD()
      ;** add logo
      IF NOT (keyword_set(NOLABEL) or keyword_set(NOLOGO)) THEN cimg = ADD_LASCO_LOGO(cimg)
      ;WDELETE

   videoimg = cimg(0:1023,128:895)
IF NOT(keyword_set(NOLABEL)) THEN BEGIN
  ; WINDOW,xsiz=1024,ysiz=768,/pixmap,/free
  device,set_resolution=[1024,768]
   tv, videoimg
   RTMVIXY, timestamp,XY=[35,40]
   videoimg = TVRD()

   IF NOT(keyword_set(PICT)) THEN videoimg = ADD_LASCO_LOGO(videoimg)
  ; WDELETE
ENDIF
set_plot,'x'
   videoimg = CONGRID(videoimg,640,480,/interp)
;window,xsiz=1024,ysiz=1024
;tv,cimg
;stop
   RETURN, cimg

END
