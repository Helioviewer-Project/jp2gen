
FUNCTION HV_MAKE_IMAGE_C2, img, hdr, FIXGAPS=fixgaps, VIDEOIMG=videoimg, $
	PICT=pict, NOLOGO=nologo, NOLABEL=nolabel, RDIFF=rdiff

;
; Keywords:
; FIXGAPS	Set to use previous image to replace missing data
; VIDEOIMG	Set to a variable which will contain television-ready image
;  NOLOGO	Put time stamp but not logo
;  NOLABEL	Do not put time stamp or logo
;  PICT		Do not add LASCO logo to video-format image
;
;Modified:
; 1999/02/05	N B Rich	Change bmin,bmax to base on median
; 1999/05/17	N B Rich	Add FIXGAPS keyword, common block
; 1999/05/25	N B Rich	Set fillcol
; 1999/06/01	N B Rich	Set box_avg when good(0) LT 0
; 1999/09/21	NB Rich		Use SOLAR_EPHEM instead of GET_SOLAR_RADIUS
; 2000/03/30	NB Rich		Add border (2 pixels)
; 2000/05/25	NBR	WINDOW,5 for pixmap
; 2000/06	NBF	Add VIDEOIMG,PICT options
; 2001/04/09	NBR	Check for bad image
; 2002/09/20	NBR	Add NOLOGO and NOLABEL
; 2003/01/27	NBR	Add /BIAS to reduce_std_size and /FFV to getbkgimg
; 030128	Jake	changed ind00 to read cimg not img
;	030717	jake	accounting for rolled images
;	030721	jake	moved roll checking for model to getbkgimg
;  2003.12.22, nbr - add RDIFF keyword; move FIXGAPS before ratio
;  Jan17,2008 -- Karl Battams -- switch to z-buffer instead of pixmaps -- much better for Linux
;
;
; 01/17/08 @(#)make_image_c2.pro	1.10 : NRL LASCO IDL Library
;
  COMMON RTMVI_COMMON_IMG, prev2,prev3,prev195,prev171,prev284,prev304,box_avg_prev2,box_avg_prev3

  m0 = median(img)
  IF m0 LT 1000 THEN return, -1
  model_all=0                   ; set 02/11/99, NBR	
  model_any_year=0		; set 12/18/00, NBR
  LOADCT, 3
  r_occ = 2.3                   ; 9/20/02, nbr ;2.2
  r_occ_out = 8.0
  fillcol=86
  dmax=100
  dmin=-100

                                ;IF (hdr.lebxsum)^2 + (hdr.sumcol)^2 GT 2 THEN stop ;
  cimg = REDUCE_STD_SIZE(img,hdr,/bias,/FULL)
  ind00 = where(cimg LE 0)	;JAKE-030128 changed img to cimg

  imgm = GETBKGIMG(hdr, mhdr, ALL=model_all,/ffv, ANY_YEAR=model_any_year)

                                ;bias = OFFSET_BIAS(hdr, /SUM)
                                ;cimg=img
  cimg = FLOAT(cimg)            ;	bias subtracted in reduce_std_size

  timestamp = STRMID(hdr.date_obs + ' ' + hdr.time_obs, 0, 16)

  sz = SIZE(cimg)
  hsize = sz(1)
  vsize = sz(2)

      ;bx1 = (hsize)/2-100
      ;bx2 = bx1+199
      ;by1 = vsize-30
      ;by2 = vsize-1
  bx1 = 0
  bx2 = hsize-1
  by1 = 0
  by2 = vsize-1

  box=[bx1,bx2,by1,by2]
  box_ref=1500.
  print,"box: ",box
                                ;WINDOW, 5, XSIZE=hsize, YSIZE=vsize, /PIXMAP
  set_plot,'z'
  device,set_resolution=[hsize,vsize] 
  
  box_img = DOUBLE(cimg(box(0):box(1),box(2):box(3)))
      ;box_imgr = DOUBLE(img(box(0):box(1),box(2):box(3)))
  good = WHERE(box_img GT 0)
  IF (good(0) GE 0) THEN box_avg=TOTAL(box_img(good))/N_ELEMENTS(good) ELSE BEGIN
     good = where (cimg GT 0,n)
     box_avg=TOTAL(cimg(good))/n
  ENDELSE
  help,box_ref,box_avg

  cimg = TEMPORARY(cimg) * (box_ref/box_avg) ;** normalize to counts in box

  nonzero = WHERE(imgm NE 0)
      
      ; ** FIXGAPS and running diff **
      
  IF KEYWORD_SET(FIXGAPS) THEN BEGIN
     IF (ind00(0) NE -1) THEN BEGIN ;** gaps in this image
        IF (fixgaps EQ 1) or DATATYPE(prev2) EQ 'UND' THEN BEGIN
           cimg(ind00) = fillcol
        ENDIF ELSE BEGIN
;           print,hdr.date_obs + ' ' + hdr.time_obs
;           read,dummy
           cimg(ind00) = prev2(ind00)*box_avg_prev2/box_avg ;** fill gaps in this img with prev image
        ENDELSE
     ENDIF
  ENDIF	
  IF datatype(prev2) NE 'UND' THEN BEGIN
     IF ( hdr.crota1 eq 180. ) THEN rdiff = rotate(cimg-prev2,2) ELSE rdiff = cimg - prev2
     tvscl, rdiff<dmax>dmin
     RTMVIXY, timestamp
     rdiff = tvrd()
  ENDIF
  prev2 = cimg
  box_avg_prev2 = box_avg
  
                                ;** ratio **
  
  cimg(nonzero) = TEMPORARY(cimg(nonzero)) / imgm(nonzero) ;take ratio of image to model
  
  nz = where(cimg GT 0)
  m = median(cimg(nz))
  
  bmin = m - 0.2
  bmax = m + 0.4
;  print,'******************************'
;  print,m,bmin,bmax,n_elements(nz),min(cimg(nz)),max(cimg(nz)),box_avg
;  print,min( imgm(nonzero) ), max( imgm(nonzero) )
;  print,'******************************'
;  set_plot,'z'
;  TVLCT, r, g, b, /GET
  
  cimg = BYTSCL(cimg, bmin, bmax)
;  read, dummy2

  ;; sunc = GET_SUN_CENTER(hdr, /NOCHECK,full=hsize)
  ;; arcs = GET_SEC_PIXEL(hdr, full=hsize)

  ;;                               ;asolr = GET_SOLAR_RADIUS(hdr)
  ;; yymmdd=UTC2YYMMDD(STR2UTC(hdr.date_obs+' '+hdr.time_obs))
  ;; solar_ephem,yymmdd,radius=radius,/soho
  ;; asolr = radius*3600
  ;; r_sun = asolr/arcs
  ;;                               ;fillcol=median(cimg(nz))
  
  ;;                               ;** draw mask
  ;; tmp_img = cimg & tmp_img(*) = 0 & TV,tmp_img
  ;; TVCIRCLE, r_occ_out*r_sun,sunc.xcen,sunc.ycen, /FILL, COLOR=1
  ;; tmp_img = TVRD()
  ;; ind1 = WHERE(tmp_img NE 1)
  ;; IF (ind1(0) NE -1) THEN cimg(ind1) = fillcol
  
  ;; cimg(0:1,*)		= fillcol ; add border
  ;; cimg(vsize-2:vsize-1,*)	= fillcol
  ;; cimg(*,0:1)		= fillcol
  ;; cimg(*,hsize-2:hsize-1)	= fillcol


  ;; TV, cimg
  ;; TVCIRCLE, r_occ*r_sun, sunc.xcen, sunc.ycen, /FILL, COLOR=fillcol

  ;;                               ;** draw limb
  ;; TVCIRCLE, r_sun, sunc.xcen, sunc.ycen, COLOR=255, THICK=4

  ;; IF hsize LT 1024 THEN BEGIN
  ;;    cimg = TVRD()
  ;;    cimg = REBIN(cimg,1024,1024)
  ;;                               ;WINDOW,xsiz=1024,ysiz=1024,/pixmap
  ;;    device,set_resolution=[1024,1024]
  ;;    tv,cimg
  ;; ENDIF

  ;; IF ( hdr.crota1 eq 180. ) THEN BEGIN      ;	jake 030717
  ;;    print, "Rotating image."               ;	jake 030717
  ;;    cimg = ROTATE ( TVRD(), 2 )            ;	jake 030717
  ;;    TV, cimg                               ;	jake 030717
  ;; ENDIF                                     ;	jake 030717

  ;; IF NOT keyword_set(NOLABEL) THEN RTMVIXY, timestamp
  ;; cimg = TVRD()
  ;;                               ;** add logo
  ;; IF not ( keyword_set(NOLOGO) or keyword_set(NOLABEL) ) THEN cimg = ADD_LASCO_LOGO(cimg)
  ;;                               ; WDELETE
  
  ;; videoimg = cimg(0:1023,128:895)
  ;;                               ; WINDOW,xsiz=1024,ysiz=768,/pixmap,/free
  ;; device,set_resolution=[1024,768] 
  ;; tv, videoimg
  ;; RTMVIXY, timestamp,XY=[35,40]
  ;; videoimg = TVRD()
  
  ;; IF NOT( keyword_set(PICT) or keyword_set(NOLOGO) ) THEN videoimg = ADD_LASCO_LOGO(videoimg)
  ;; videoimg = CONGRID(videoimg,640,480,/interp)
  
  ;;                               ; WDELETE
  ;; set_plot,'x'
  RETURN, cimg

END
