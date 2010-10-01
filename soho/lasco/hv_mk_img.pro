;+
; Project     : SOHO - LASCO/EIT
;                   
; Name        : MK_IMG
;               
; Purpose     : Process FITS files for display.
;               
; Explanation : This procedure  reads an image and 
;		normalizes to the exposure time.
;		(Not implemented: The on_off_diff keyword results in a movie
;               where each on line image is displayed with a nearby offband image
;               subtracted.)
;               
; Use         : result = MK_IMG( filename, bmin, bmax, /TIMES, /DIFF, /NO_NORMAL, $
;                        UNSHARP=unsharp, PAN=pan, COORDS=coords, BOX=box, $
;                        /RATIO, /USE_MODEL,/FLAT_FIELD,/ON_OFF_DIFF,/MASK_OCC,/LG_MASK_OCC,
;                        /RADIAL, /DEGRID, /FIXGAPS, /LOG_SCL, /SQRT_SCL, $
;			 FILL_COL=fill_col, SAVE=save)
;
;      Example: IDL> result = MK_IMG( '32002333.fts', -100, 100, shdr, /DIFF)
;
;      Example: If you want to display BYTARR images straight from the FITS files without
;		any scaling use:
;               IDL> result = MK_IMG( filename, 0, 255, /NO_NORMAL)
;    
; Inputs      : filename : string containing the filename
;               bmin, bmax : Minimum and maximum DN for BYTSCL.
;               
; Outputs     : processed image array.
;		shdr	STRARR	FITS header as a string array
;               
; Keywords    : The following keywords apply to all telescopes (C1,C2,C3,EIT)
;
;	
;	POINTFILT  : Implements point_filter on raw image; set equal to [boxsize, sensitivity, iterations]
;			default is [5,7,3]
;	SUNC	   ; Returns sun center structure {xcen, ycen}
;	BKG	   ; Set equal to background image to use instead of GETBKGIMG; should 
;		 	be normalized to exptime and correctly sized
;	/INIT1	   ; Set to reset COMMON block; MK_IMG always returns zero for this value
;	/EXPFAC    ; set equal to variable which contains exp correction factor 
;		 	(-1 if not found)
;	/ROLL      : Apply roll correction if GT 2 deg.; returns value of roll angle 
;	/LIST	   : for use with PROCESS_LIST procedure
;	/LOGO	   ; Add LASCO logo to bottom right corner
;	/OUTMASK   : apply outer mask only
;	/INMASK    : apply occulter mask only
;	/NO_DISPLAY: do not display image as it is processed
;	/NX	   : Desired final size of image; superseded by PAN
;	/CREM	   : Set this keyword if doing CR removal; filename in or will prompt
;	/HIDE_PYLON: Replace (byte) values below setting with median
;	/DBIAS	   : Add this to bias before subtracting
;	/NORM	   : Apply linear normalization function based on image median (5/99)
;	/DO_BYTSCL : Apply bytescaling (default is not to)
;	/LEE_FILT  : Apply LEEFILT function to filter noise.
;       /TIMES     : Set this keyword to display date and time in images.
;	/DIFF      : Set this keyword to make a difference image.  The 
;			     model is subtracted.
;	/NO_NORMAL : Don't normalize exposure times to that of the first image.
;	/NO_SORT   : Don't sort by time in header.
;       UNSHARP    : Set this keyword to make a movie of unsharp masked images.
;                    The value of the keyword if any is set to the size of the
;                    unsharp mask, default=25
;                    Example:  A value of 9 would form a 9x9 unsharp mask
;	/RATIO     : If using diff or running_diff display data as ratio of 
;			image/reference frame
;       /MASK_OCC  : applies a sun sized circle and removes the internal part of the 
;			image and masks outer image
;	/LOG_SCL   : Applies ALOG10() function to image before byte scaling
;	/SQRT_SCL  : Applies SQRT() function to image before byte scaling
;	/FIXGAPS   : Set to 1 to fill data gaps in image with color specified by 
;			FILL_COL
;		     Set to 2 to fill data gaps in image with values from previous 
;			image
;	FILL_COL   : Set this keyword to the color index to use for data gaps and 
;			occ masks.
;	SAVE       : For use in batch mode.  Set this keyword to the name of the 
;			.mvi file to save as.  Routine will save movie and then exit.
;	PAN        : Default is to resize images to pixel size of the first image.  
;			Set this keyword to perform additional scaling.  
;			Example: set to 0.5 for 2x2 rebinning.
;	COORDS     : Set to 4 element array of image coordinates to use relative to 
;			1024x1024 image.
;		 	Example: COORDS=[0,1023,128,895] for C2 Equatorial Field
;	BOX        : Set to 4 element array of image coordinates to use for box 
;			normalization relative to 1024x1024 image. Images are scaled 
;			relative to average counts in box of first image. 
;			Example: BOX=[461,560,641,740]
;	REF_BOX    : Set to avg counts specified in BOX otherwise first image is used
;
;      : The following keywords apply only to C1
;
;       /ON_OFF_DIFF: differences each on line image with an image taken at a continuum 
;			wavelength
;       /FLAT_FIELD : normalizes each image by a door closed image to remove the solar 
;			spectrum
;       /RADIAL	    : applies a radial filter
;
;      : The following keywords apply only to C2 and C3
;
;	/USE_MODEL : If using diff or running_diff use background corona model
;                 as base frame.  USE_MODEL=1 for closest any_year monthly model
;                                 USE_MODEL=2 for closest monthly model (1 year)
;                                 USE_MODEL=3 for for overall yearly model
;	/DISTORT   : Apply distortion correction for C2 or C3
;
;       : The following keywords apply only to EIT
;
;       /DEGRID	   : applies the degridding algorithm
;
; Calls       : 
;
; Side effects: 
;               
; Category    : Image Display.
;               
; See Also    : 
;               
;               
; Prev. Hist. : None.
;
; Written     : Nathan Rich, NRL/Interferferometrics, 17 Dec 1998
;	Based on MKMOVIE.PRO by Scott Paswaters, NRL, Jan 1996.
;               
; Modified    : SEP 29 May 96 - Place frames into multiple pixmaps instead of 1 large
;				pixmap because of limitations on window size in IDL.
;               SEP  9 Jul 96 - Read in img headers as structures and pass to wrunmovie
;               SEP 18 Oct 96 - Add option to pass in STRARR of image names instead of filename.
;               SEP 24 Oct 96 - added /RATIO and /USE_MODEL options
;               RAH 13 Dec 96 - added check for daily median image which doesn't have bias
;               CMK 16 Feb 97 - added all C1 related features and changed the procedure name to mkc1movie2
;           RAH/SEP 14 Mar 97 - integrated mkc1movie2 features into mkmovie
;               SEP 21 Mar 97 - corrected bias subtraction for LEB summed images
;               SEP 01 Oct 97 - added /SUM keyword to OFFSET_BIAS call
;               SEP 22 Oct 97 - fixed divide by zero error for /RATIO option
;               SEP 31 Oct 97 - Binned images are scaled (/bin^2) for level_05 images only
;               SEP 13 Nov 97 - Added /FLAT_FIELD for EIT, added /NEW flag to EIT_DEGRIDN
;               RAH 02 Feb 98 - Now normalizes to calculated exposure time (if data exists).
;		NBR 06 Nov 98 - Change default fillcol to median(image); change LG_MASK_OCC for c3 to use C3clearmask2.dat
;		NBR 17 Dec 98 - Change to MK_IMG; add LEE_FILT, NO_BYTSCL, DISTORT keywords
;		NBR 04 Dec 99 - Add default bmin and bmax
;		nbr 13 Apr 99 - ALlow replace gaps with prev image
;		nbr 17 May 99 - Add FNAME keyword
;		nbr    Jul 99 - use first of two filename strings in 'fullname' to remove CRs; Move Leefilt before BYTSCL; Make MASK_OCC work for non-byte results; change HIDE_PYLON
;		nbr    Aug 99 - Add NX keyword
;		nbr    Sep 99 - Add NO_DISPLAY keyword, add OUTER keyword; Use updated EIT_DEGRID, EIT_FLAT
;		nbr    Mar 00 - Automatically correct for different bias value in bkg model for c3 (default); use INMASK and outmask keywords; add LIST keyword; add 1 to image for ALOG10 to prevent negative output
;	nbr  May 00 - Change USE_MODEL numbering; add shdr output; change NO_BYTSCL to DO_BYTSCL
;	nbr  Oct 00 - Add NO_PROFILE, INIT1 keywords; use one value for maskfill when doing a list; 
;			add EIT_NORM_RESPONSE and make DEGRID and FLATFIELD automatic for EIT
;	nbr  Nov 00 - Change mask radius for C2 LG_MASK_OCC; add CIRC_WIDTH keyword; 
;	nbr, 21Nov00 - Accept image array as input for fullname
;	nbr,  4Apr01 - Always use any_year=0 for images after 2000/12/03
;	nbr, 11Apr01 - Change r_occ_out for C2
;	nbr,  1Jun01 - Move REMOVE_CR and RUNNING_DIFF to before ratio/difference
;	nbr,  8Jun01 - Use EIT_PREP; move READFITS to middle; add PROFILE keyword and use wset
;			for profile
;	nbr, 17Jul01 - Use separate mask for pylon and c3mask; change how dbias is computed for C3
;	nbr, 18Jul01 - Increase upper limit for HIDE_PYLON
;	nbr, 20Nov01 - Add BKG keyword; do not match pylon if BKG is set
;	nbr, 13Dec01 - Fix lower left corner mask problem
;	nbr, 13Mar02 - Implement ROLL keyword
;	nbr,  1Apr02 - DON'T divide EIT images by exptime
;	nbr,  8Apr02 - Modify [hv]size, f[hv]size
;	nbr,  7Aug02 - Add images common block
;	nbr, 18Sep02 - Add POINTFILT keyword; add some VERBOSE comments
;	nbr,  3Sep03 - Add COMMON get_im for logging with carrmapmaker2.pro
;	nbr, 15Jan04 - Add header values, fix roll, add FILL_COL
;   	nbr, 25Apr06 - Replace all instances of "image" with "imaje" because of conflict with IDL pro of same name
;	nbr, 25Apr06 - Use new ROLL keyword in get_sun_center.pro
;   	nbr, 20Sep06 - Assume ffv output unless COORD; fix bmax for subfield
; Version     : 
;
; @(#)mk_img.pro	1.11 10/03/06 :NRL Solar Physics
;
;-            
 
;____________________________________________________________________________
;

FUNCTION MK_IMG, fullname, bmin, bmax, shdr,LEE_FILT=lee_filt, DIFF=diff, TIMES=times, $
EXPFAC=efacb, RUNNING_DIFF=running_diff, NO_NORMAL=no_normal, DO_BYTSCL=do_bytscl, $
DISTORT=distort, NO_SORT=no_sort, UNSHARP=unsharp, RATIO=ratio, USE_MODEL=use_model, $
AUTOMAX=automax, MASK_OCC=mask_occ, FIXGAPS=fixgaps, DEGRID=degrid, LOG_SCL=log_scl, $
NORM=norm, LIST=list, ON_OFF_DIFF=on_off_diff,FLAT_FIELD=flat_field,INMASK=inmask, $
FNAME=fname, LOGO=logo, RADIAL=radial, SQRT_SCL=sqrt_scl, FILL_COL=fill_col, PAN=pan, $
COORDS=coords, DBIAS=dbias, BOX=box, SAVE=save, REF_BOX=box_ref, USE_SHARP=use_sharp, $
SHARP_FACTOR=sharp_factor, HIDE_PYLON=hide_pylon, CREM=crem, NX=nx, NO_DISPLAY=no_display, $
OUTMASK=outmask, NOCAM=nocam, NO_PROFILE=no_profile, LG_MASK_OCC=lg_mask_occ, $
CIRC_WIDTH=circ_width, PROFILE=profile, BKG=bkg, NO_PYLON_OFFSET=no_pylon_offset, ROLL=roll, $
SUNC = sunc, POINTFILT=pointfilt

COMMON images, prev,hprev, startind, i, init1
COMMON get_im, on_s,on_times,ff_ratio, cmhdr, cmprev, pylonim, lulog, ffv
COMMON ji_images, ji_prev,ji_hprev


csize = 1.5
IF not(keyword_set(DBIAS)) THEN dbias=0
prevf=''
nuthin=''
sz = SIZE(fullname)
IF sz(0) EQ 1 AND NOT(keyword_set(LIST)) AND keyword_set(INIT1) THEN z=1 ELSE z=0
IF NOT(keyword_set(LIST)) THEN i=0
IF datatype(staind) EQ 'UND' THEN BEGIN
	staind_ok=1 
	staind=0
ENDIF ELSE IF staind EQ 0 THEN staind_ok=1 ELSE staind_ok=0

IF  (keyword_set(CREM) OR keyword_set(FIXGAPS)) AND keyword_set(INIT1) AND sz(0) EQ 0 $
  AND NOT(keyword_set(LIST)) THEN BEGIN
	if fixgaps EQ 1 THEN goto, goon
	read,'Please enter name of previous image file (no path): ',prevf
	break_file,fullname,dl,dir,filename,ext
	prevf=dir+prevf
	fullname=[prevf,fullname]
	z=1
	staind=0
ENDIF
goon:

FOR j=0,z DO BEGIN	; loop for doing CREM or FIXGAPS, if necessary	
;*****************
   t1=systime(1)
   IF sz[0] NE 2 THEN BEGIN
   	count=1
   	print,'Reading ',fullname(j)
   	;imaje = READFITS(fullname(j), shdr)
	shdr0 = HEADFITS(fullname[j])
   	t2=systime(2)
	IF datatype(lulog) NE 'UND' THEN printf,lulog,systime()+'; '+trim(string(t2-t1))+'; seconds for HEADFITS '+fullname[j]
   	print,'HEADFITS took',t2-t1 ,' seconds.'
	dtyp = datatype(shdr0)
   	IF dtyp NE 'STR' THEN REPEAT BEGIN
		IF count GT 20 THEN message,'Unable to read '+fullname[j]+' after 10 minutes.'
		IF datatype(lulog) NE 'UND' THEN printf,lulog,systime()+'; FAIL '+fullname[j]
		print,'Read failed.'
	  	wait,30
	  	shdr0=HEADFITS(fullname[j])
	  	dtyp = datatype(shdr0)
		count=count+1
  	ENDREP UNTIL dtyp EQ 'STR' 
   ENDIF ELSE BEGIN
	imaje = fullname
   ENDELSE
   hdr = LASCO_FITSHDR2STRUCT(shdr0)		; nbr, 5/23/00
   fxhmake,shdr,/init

   cam = TRIM(hdr.detector)

   IF (DATATYPE(hdr) EQ 'STC') THEN BEGIN
; ** copied from reduce_level_1.pro
fxaddpar,shdr,'NAXIS',2
fxaddpar,shdr,'NAXIS1',1024
fxaddpar,shdr,'NAXIS2',1024
fxaddpar,shdr,'FILENAME',hdr.filename
fxaddpar,shdr,'FILEORIG',hdr.fileorig
fxaddpar,shdr,'DATE-OBS',hdr.date_obs
fxaddpar,shdr,'TIME-OBS',hdr.time_obs
fxaddpar,shdr,'EXPTIME', hdr.exptime
fxaddpar,shdr,'TELESCOP',hdr.telescop
fxaddpar,shdr,'INSTRUME',hdr.instrume
fxaddpar,shdr,'DETECTOR',hdr.detector
fxaddpar,shdr,'READPORT',hdr.readport
fxaddpar,shdr,'LEBXSUM', hdr.lebxsum
fxaddpar,shdr,'LEBYSUM', hdr.lebysum
fxaddpar,shdr,'FILTER',  hdr.filter
fxaddpar,shdr,'POLAR',   hdr.polar
fxaddpar,shdr,'COMPRSSN',hdr.comprssn
fxaddpar,shdr,'R1COL',   hdr.r1col
fxaddpar,shdr,'R1ROW',   hdr.r1row
fxaddpar,shdr,'R2COL',   hdr.r2col
fxaddpar,shdr,'R2ROW',   hdr.r2row
; **
	exp_cmd = hdr.expcmd    		;** commanded exposure time
	exp_dur = hdr.exp0		;** actual delay measure by OBE
	date_obs = hdr.date_obs
	time_obs = hdr.time_obs
	IF cam NE 'EIT' THEN BEGIN
		IF (GET_EXP_FACTOR(hdr,efac,bias) NE 0)  or keyword_set(BOX) THEN BEGIN
            		IF keyword_set(VERBOSE) THEN PRINT, $
			'Exposure factor not found or ignored for '+date_obs+' '+time_obs
            		efac = 1.
	    		efacb=-1
         	ENDIF ELSE efacb = efac 
	ENDIF ELSE BEGIN
		IF keyword_set(VERBOSE) THEN print,'No exposure factor for EIT.'
		efac = 1.
                efacb=-1
		bias = offset_bias(hdr)
	ENDELSE
         exp = hdr.exptime*efac        	;** actual delay measure by OBE
	 IF efacb NE -1 THEN BEGIN
		FXADDPAR,shdr,'EXPTIME',exp,' Corrected.'
	 	FXADDPAR,shdr,'HISTORY','Used exposure correction factor of '+TRIM(STRING(efac))
	 ENDIF ELSE fxaddpar,shdr,'EXPTIME',hdr.exptime,' Uncorrected.'
         fpwvl=hdr.waveleng
         filter=hdr.filter
   ENDIF

help,efac
   IF KEYWORD_SET(SHARP_FACTOR) THEN sharp_fact = sharp_factor ELSE sharp_fact = 0.015
   

;IF KEYWORD_SET(TIMES) THEN BEGIN
	;times = date_obs+' '+time_obs
	time = strmid(date_obs+' '+time_obs,0,16)
;	setfont
;ENDIF

   ind0 = -1
   ind00 = -1
   IF keyword_set(NOCAM) THEN label=time ELSE label=cam+'  '+time

   ;** save rebin params and imaje coords
   IF keyword_set(COORDS) THEN BEGIN
	fxaddpar,shdr,'R1COL',   coords[0]+20
	fxaddpar,shdr,'R1ROW',   coords[2]+1
	fxaddpar,shdr,'R2COL',   coords[1]+20
	fxaddpar,shdr,'R2ROW',   coords[3]+1
   ENDIF
   IF KEYWORD_SET(PAN) THEN BEGIN
	img_pan=pan 
	IF keyword_set(COORDS) THEN coords=coords*pan
	fxaddpar,shdr,'LEBXSUM', 1./img_pan
	fxaddpar,shdr,'LEBYSUM', 1./img_pan
   ENDIF ELSE BEGIN
	img_pan=1.
   ENDELSE
   IF keyword_set(NX) THEN BEGIN
	img_pan = float(nx)/(img0_xy[1]-img0_xy[0]) 
   ENDIF

   IF KEYWORD_SET(COORDS) THEN BEGIN
	img0_xy=coords
   ENDIF ELSE BEGIN	;** assume ffv
	img0_xy=intarr(4)
	img0_xy[0]=0
	img0_xy[1]=1023
	img0_xy[2]=0
	img0_xy[3]=1023
   ENDELSE

;   img0_pan=(1./(hdr.sumcol>1))*(1./(1>hdr.lebxsum))*img_pan


   IF KEYWORD_SET(BOX) THEN box1 = box ELSE box1 = [260,780,50,1020]*img_pan
   IF img_pan LE 0.5 THEN BEGIN
	dofull=0 
	fhsize = 512
	fimg_pan = 0.5
   ENDIF ELSE BEGIN
	dofull=1
	fhsize = 1024
	fimg_pan = 1
   ENDELSE
   hsize = fix(img_pan*(img0_xy[1]-img0_xy[0]+1))
   vsize = fix(img_pan*(img0_xy[3]-img0_xy[2]+1))
fxaddpar,shdr,'NAXIS1',hsize
fxaddpar,shdr,'NAXIS2',vsize
; ** vsize and hsize are the actual size of the output
; ** f[vh]size is [1024,1024] or [512,512]
   img0_xy = FIX(img0_xy*fimg_pan)	; for extracting subfield after processing
   fvsize = fhsize
help,fhsize

   sunc = GET_SUN_CENTER(hdr, src1, FULL=fhsize, /NOCHECK,/DEGREES,ROLL=sroll)
   if src1 EQ 'OCC' THEN src1='occulter'
;   sunc.xcen = sunc.xcen+hdr.r1col-20
;   sunc.ycen = sunc.ycen+hdr.r1row-1
;   sroll = GET_SOLAR_ROLL(hdr, src2, /MEDIAN)
;   pnt = GET_SC_POINT(time,/retain)
;   src2='ATDEF (SOHO roll)'
;   sroll = pnt.sc_roll ; degrees
   ;IF src1 NE 'OCC' THEN BEGIN
   ;ENDIF
   ;sroll = get_roll_or_xy(hdr,'roll',src2,/avg,/degrees)
   doroll=0
help,sroll
   arcs = GET_SEC_PIXEL(hdr, FULL=fhsize)
   ;asolr = GET_SOLAR_RADIUS(hdr)
   yymmdd = strmid(date_obs,2,2)+strmid(date_obs,5,2)+strmid(date_obs,8,2)
   solar_ephem,yymmdd,radius=radius,/soho	; **good enough. nbr, 6/20/00
   asolr=radius*60*60
   r_sun = asolr/arcs
print,sunc
;   hsize=hsize*img0_pan
;   vsize=vsize*img0_pan
; Center for FFV image   sunxcen=(sunc.xcen)	
   sunxcen=sunc.xcen
   sunycen=(sunc.ycen)	

   crpix_x = (sunc.xcen+1-img0_xy[0])	*img_pan/fimg_pan
   crpix_y = (sunc.ycen+1-img0_xy[2])	*img_pan/fimg_pan
   FXADDPAR,shdr,'CRPIX1',crpix_x,'From '+src1
   FXADDPAR,shdr,'CRPIX2',crpix_y,'From '+src1
   sec_pix=arcs
   platescl=sec_pix
FXADDPAR,shdr,'CDELT1',platescl,' Arcsec/pixel'
FXADDPAR,shdr,'CDELT2',platescl,' Arcsec/pixel'
FXADDPAR,shdr,'XCEN',0+platescl*((hsize+1)/2. - crpix_x),' Arcsec'
FXADDPAR,shdr,'YCEN',0+platescl*((vsize+1)/2. - crpix_y),' Arcsec'

   IF (KEYWORD_SET(FLAT_FIELD) AND (STRLOWCASE(hdr.detector) EQ 'c1')) THEN BEGIN
      IF filter NE 'Fe XIV' THEN BEGIN
         factoroff = 1.0
         factoron = 1.0
         PRINT, '%%MK_IMG: FLAT_FIELD option currently only works for C1 Fe XIV'
      ENDIF ELSE BEGIN
      offband=5309
      ;find on band wavelength
      flag=0
      dummy_count=0
      CD,GETENV('NRL_LIB')+'/lasco/data/calib',curr=currdir
      IF onband EQ 5302.4222 THEN flaton=readfits('12014004.fts',flatonhdr)
      IF onband EQ 5302.7273 THEN flaton=readfits('12014017.fts',flatonhdr)
      IF offband EQ 5309 THEN flatoff=readfits('12014005.fts',flatoffhdr)
      CD,currdir
      offset=369
      flfldon =(FLOAT(flaton-offset)/FXPAR(flatonhdr,'exptime'))/25.0
      flfldoff=(FLOAT(flatoff-offset)/FXPAR(flatoffhdr,'exptime'))/25.0

       IF flfldon le 0.0 THEN flfldon=1.0
      IF flfldoff le 0.0 THEN flfldoff=1.0

      factoroff=1.0/flfldoff
      factoron=1.0/flfldon
      factoroff = REDUCE_STD_SIZE(factoroff, flatoffhdr, FULL=DOFULL);** make all imajes 1024x1024 or 512x512
      factoron = REDUCE_STD_SIZE(factoron, flatonhdr, FULL=DOFULL);** make all imajes 1024x1024 or 512x512

      ENDELSE
   ENDIF
   IF KEYWORD_SET(RADIAL) THEN BEGIN
       CD,GETENV('NRL_LIB')+'/lasco/data/calib',curr=currdir
       radial=readfits('C1_radial.fts', radialhdr)
       CD,currdir
       radial=float(radial) / 100
       radial = REDUCE_STD_SIZE(radial, radialhdr, FULL=DOFULL);** make all imajes 1024x1024 or 512x512
   ENDIF
   


   ;IF (KEYWORD_SET(MASK_OCC)) OR KEYWORD_SET(LG_MASK_OCC) THEN BEGIN
      CASE STRLOWCASE(hdr.detector) OF
      'c1' : BEGIN
                r_occ = r_sun * 1.2
                ;IF KEYWORD_SET(LG_MASK_OCC) THEN r_occ=r_sun * 1.2
                r_occ_out = r_sun * 3.0
             END
      'c2' : BEGIN
                r_occ = r_sun * 2.2
                IF KEYWORD_SET(LG_MASK_OCC) THEN r_occ=r_sun * 2.3
                r_occ_out = r_sun * 7.8
             END
      'c3' : BEGIN
                r_occ = r_sun * 4.3
                r_occ_out = r_sun * 31.5
                c3mask=-1
                ;IF KEYWORD_SET(LG_MASK_OCC) THEN BEGIN
                   CD,GETENV('NRL_LIB')+'/lasco/data/calib',curr=currdir
                   c3mask=READFITS('c3clearmask2.fts')
                   c3maska=READFITS('c3clearmask2a.fts')
		   IF not DOFULL THEN BEGIN
                   	c3mask = REBIN(c3mask, fhsize, fvsize)
                   	c3maska = REBIN(c3maska, fhsize, fvsize)
		   ENDIF
                   CD,currdir
		   pylon = where(c3maska EQ 3)
                ;ENDIF
             END
      ELSE :
      ENDCASE
   ;ENDIF
 

;**
;** START C1
;**
IF KEYWORD_SET(ON_OFF_DIFF) THEN BEGIN
	print,' This program is not modified to do C1.'
	return,-1
	;
	;
	; ** insert contents of "mk_img_c1.txt" here
	;
	;
;**
;** END C1
;**

ENDIF ELSE BEGIN
   yloc = 0
   ref_exp = exp
   startind = 1
   all = 0
;
;*******************************;
;   Begin image processing	;
;				;
;*******************************;
;

   IF cam EQ 'EIT' THEN eit_prep,fullname[j],eithdr,imaje, /resp, /nrl, /float, /filter, fill=fltarr(32,32) $

   ; *********** Begin NOT EIT
   ELSE BEGIN
;stop
;      imgbias = OFFSET_BIAS(hdr, /SUM)
;      imgbias = bias	+dbias
      IF sz[0] NE 2 THEN imaje = lasco_readfits(fullname[j],hdr)
	IF keyword_set(POINTFILT) THEN BEGIN
		IF n_elements(pointfilt) LT 3 THEN pointfilt=[7,3,2]
		point_filter,temporary(imaje),pointfilt[0],pointfilt[1],pointfilt[2],imaje
	ENDIF
      imgbias = bias
      IF NOT(KEYWORD_SET(NO_NORMAL)) AND (STRMID(hdr.filename,1,2) NE 'd_') AND (STRMID(hdr.filename(0),1,2) NE 'm_') $
	THEN BEGIN
	   print,'Using bias =',imgbias
	   FXADDPAR,shdr,'OFFSET',0
	   FXADDPAR,shdr,'HISTORY','Subtracted bias of '+TRIM(STRING(imgbias))
           imaje = imaje - imgbias 
           ;IF (ind00(0) NE -1) THEN imaje(ind00) = 0
      ENDIF
   ENDELSE
   ; ************ End NOT EIT

      imaje = REDUCE_STD_SIZE(imaje, hdr, FULL=DOFULL)   ;** make all imajes 1024x1024 or 512x512
	; ** Subfields are placed in a ffv square either 1024x1024 or 512x512
      ;** if file is a level_05 imaje then counts are in DN and we need to account for pixel summing
      ;** file is level_05 if name is tsxxxxxx and t <=4 and s <=3
      BREAK_FILE, fullname(j), a, dir, name, ext
      IF ( (STRLEN(name) EQ 8) AND (VALID_NUM(STRMID(name,1,1)) ) AND (VALID_NUM(STRMID(name,0,1)) ) ) THEN BEGIN
         IF ( (FIX(STRMID(name,1,1)) LE 3) AND (FIX(STRMID(name,0,1)) LE 4) ) THEN BEGIN
            IF (hdr.sumcol NE 0) THEN imaje = imaje/(hdr.sumcol)^2
            IF (hdr.lebxsum NE 0) THEN imaje = imaje/(hdr.lebxsum)^2
         ENDIF
      ENDIF

       ind00 = WHERE(imaje LE 0)
      nz = where(imaje GT 0)
	IF cam EQ 'C3' THEN BEGIN
	   goodpyl = WHERE(imaje(pylon) GT 0)
	   IF goodpyl(0) EQ -1 THEN return,imaje
	ENDIF


;stop
      
      ;IF STRLOWCASE(cam) EQ 'eit' THEN BEGIN
	;  imaje = EIT_DEGRID(imaje, shdr,/VERBOSE)
      ;    imaje = EIT_FLAT(imaje, shdr,/verbose)
	;  imn = EIT_NORM_RESPONSE(hdr.date_obs,FIX(STRMID(hdr.sector,0,3)),shdr)
	;  imaje = imaje/imn
      ;ENDIF

   IF keyword_set(INIT1) AND j EQ 0 THEN ref = imaje
   hist=''
   IF keyword_set(DIFF) THEN hist='Difference image using '
   IF keyword_set(RATIO) THEN hist='Ratio image using '
   bkhist='Manual'
   IF (KEYWORD_SET(USE_MODEL)) THEN BEGIN
         IF (use_model EQ 1) THEN any_year=1 ELSE any_year=0   ;all=1 ELSE all=0
         IF (use_model EQ 3) THEN all=1 ELSE all=0
	 ;IF hdr.date_obs GT '2000/12/03' THEN any_year=0
         imgm = GETBKGIMG(hdr, hdrm, ALL=all, /FFV, ANY_YEAR=any_year, ROLL=doroll)
	 IF cam EQ 'C3' THEN refmed = median(imgm(pylon(goodpyl)))
	 bkhist = hist+' GETBKGIMG '+hdrm.filename+' v'+strmid(hdrm.date,0,10)
         IF not DOFULL THEN imgm = REBIN(imgm, fhsize, fvsize)
	 IF (N_ELEMENTS(imgm) EQ 1) THEN BEGIN
            PRINT, '%%%MK_IMG: Model not found'
         ENDIF ELSE BEGIN
            startind = 0
            ;imaje = imgm
            ref_exp = hdrm.exptime
            ;win_index = INTARR(len)
	    imgm0=imgm
	    imaj0=imaje
	    IF NOT(KEYWORD_SET(NO_NORMAL)) THEN $
         	ref = imgm / ref_exp $	;** normalize to exposure time
		ELSE ref = imgm
            ind0=WHERE(imgm EQ 0)
         ENDELSE

      ;ref = imgm
   ENDIF 
   IF keyword_set(BKG) THEN ref = bkg 

	IF cam EQ 'C3' and NOT(keyword_set(NO_PYLON_OFFSET)) THEN BEGIN
		diffp= imaje-ref*exp
		dbias=median(diffp(pylon(goodpyl)))
		hist = 'Subtracted additional bias of '+TRIM(STRING(dbias))+' before diff/ratio.'
		print,hist
;stop
		FXADDPAR,shdr,'HISTORY',hist
		imaje = imaje-dbias
		ind00 = where(imaje LE 1)
		imaje = imaje>0
	ENDIF

      IF NOT(KEYWORD_SET(NO_NORMAL)) and cam NE 'EIT' THEN BEGIN
	; EIT_PREP does exposure time correction
         imaje = TEMPORARY(imaje) / exp				;** normalize to exposure time
	 FXADDPAR,shdr,'HISTORY','Divided by exposure time.'
      ENDIF

      IF KEYWORD_SET(BOX) AND NOT(KEYWORD_SET(BOX_REF)) THEN BEGIN
         box_img = DOUBLE(imaje(box1[0]:box1[1],box1[2]:box1[3]))
         good = WHERE(box_img GT 0)
         IF (good(0) GE 0) THEN box_ref=TOTAL(box_img(good))/N_ELEMENTS(good) ELSE box=0
      ENDIF

      IF keyword_set(NORM) THEN BEGIN
	immed = median(imaje(nz))
	tait = utc2tai(str2utc(time))
	imref = 1.0811713e-6 * tait - 1302.4592		; figured for C2 980411 - 980420
	imfactor = imref/immed
	help,imfactor
	imaje = temporary(imaje)*imref/immed
      ENDIF
      IF KEYWORD_SET(BOX) THEN BEGIN
         box_img = DOUBLE(imaje(box1[0]:box1[1],box1[2]:box1[3]))
         good = WHERE(box_img GT 0)
         IF (good(0) GE 0) THEN BEGIN
            box_avg=TOTAL(box_img(good))/N_ELEMENTS(good)
            imaje = TEMPORARY(imaje) * (box_ref/box_avg)	;** normalize to counts in box
	    FXADDPAR,shdr,'HISTORY','Box normalization with factor '+TRIM(STRING(box_ref/box_avg))

         ENDIF
	help,box_avg
	help, box_ref
      ENDIF 	;ELSE $
;stop
;
; ** Moved REMOVE_CR her because it is optimized for raw images. NBR, 6/1/01 **
;
;	nz = where(imaje GT 0)

;      IF keyword_set(CREM) and (j GT 0 or i GT staind) THEN BEGIN
      IF keyword_set(CREM) and (j GT 0) THEN BEGIN
	tempimg = imaje
	result = REMOVE_CR(prev0,hprev,tempimg,hdr,again, img_pan, init=init1)
        prev0 = imaje
	imaje = result
	init1=0
	FXADDPAR,shdr,'HISTORY','remove_cr.pro'
      ENDIF ELSE prev0 = imaje
      hprev=hdr
      IF KEYWORD_SET(RUNNING_DIFF) and NOT(keyword_set(INIT1)) THEN BEGIN
         imaje = TEMPORARY(imaje) - prev0				;** subtract previous imaje
      ENDIF

; **

      IF KEYWORD_SET(DIFF) THEN $
         imaje = TEMPORARY(imaje) - ref*DIFF			;** subtract reference imaje
      IF KEYWORD_SET(USE_SHARP) or keyword_set(UNSHARP) THEN BEGIN
	    tmp = imaje
            imaje = SHARPEN(temporary(tmp), ref, sharp_fact, BOX_SIZE=UNSHARP, NO_RATIO=UNSHARP) 
      ENDIF 

      IF KEYWORD_SET(RATIO) THEN BEGIN
         IF KEYWORD_SET(SQRT_SCL) THEN BEGIN
		imaje = SQRT(TEMPORARY(imaje)>0) / SQRT(ref>0) 
		FXADDPAR,shdr,'HISTORY','SQRT >0 applied' 
	 ENDIF ELSE IF KEYWORD_SET(LOG_SCL) THEN BEGIN
            	imaje = ALOG10(TEMPORARY(imaje)>1) / ALOG10(ref>1) 
		FXADDPAR,shdr,'HISTORY','ALOG10 applied' 
		;** divide by reference imaje
         ENDIF ELSE BEGIN 					
            nonzero = WHERE(ref NE 0)
            imaje(nonzero) = TEMPORARY(imaje(nonzero)) / ref(nonzero)				
         ENDELSE
      ENDIF
	IF keyword_set(PROFILE) THEN BEGIN
 	   wset,profile
	   plot,imaje(*,300*img_pan),back=1
	   wait,2
	ENDIF
      IF keyword_set(DIFF) or keyword_set(RATIO) THEN fxaddpar,shdr,'HISTORY',bkhist

      IF KEYWORD_SET(UNSHARP) AND NOT(KEYWORD_SET(USE_SHARP)) THEN BEGIN
	IF unsharp EQ 1 THEN uns = 25 ELSE uns = unsharp
         ;tmp = SMOOTH(imaje,uns)
         ;imaje = TEMPORARY(imaje) - tmp                         ;** subtract smoothed imaje
      ENDIF
      IF KEYWORD_SET(RADIAL) THEN imaje=imaje/radial

      IF ( KEYWORD_SET(LOG_SCL) AND NOT(KEYWORD_SET(RATIO)) ) THEN BEGIN
	 imaje=imaje+1
	 b=where(imaje le 0,dummy)
	 IF dummy ne 0 THEN imaje(b)=1
	 imaje=ALOG10(imaje)
	 FXADDPAR,shdr,'HISTORY','ALOG10 applied' 

      ENDIF
      IF ( KEYWORD_SET(SQRT_SCL) AND NOT(KEYWORD_SET(RATIO)) ) THEN BEGIN
         imaje = SQRT((imaje)>0)
	 FXADDPAR,shdr,'HISTORY','SQRT >0 applied' 

      ENDIF

;      IF keyword_set(FILL_COL) THEN fillcol = fill_col ELSE $
;      	IF nz(0) NE -1 THEN fillcol=median(imaje(nz)) ELSE fillcol=median(imaje)
fillcol=0
      IF keyword_set(INIT1) OR datatype(maskfill) EQ 'UND' THEN maskfill=fillcol

      IF KEYWORD_SET(FIXGAPS) THEN BEGIN
         IF (ind0(0) NE -1) THEN ref(ind0) = fillcol	;** gaps in reference img
         IF (ind00(0) NE -1) THEN Begin			;** gaps in this imaje
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,ind00(0)
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            print,'!!!!!!!!'
            IF ((fixgaps LT 2) or keyword_set(INIT1) or  datatype(prev) EQ 'UND') THEN BEGIN
               imaje(ind00) = fillcol 
            endif else begin
               imaje(ind00) = prev(ind00)
            endelse
         ENDIF ELSE FXADDPAR,shdr,'HISTORY','Missing blocks left as zero.'

      IF (STRLOWCASE(hdr.detector) EQ 'c3') THEN imaje(0:160.*fimg_pan,0:160.*fimg_pan)=fillcol
	help,fillcol

      prev = imaje
; **************** End NOT C1
ENDELSE

  init1=0
ENDFOR

IF keyword_set(AUTOMAX) or datatype(bmin) EQ 'UND' or datatype(bmax) EQ 'UND' THEN BEGIN
	bmin=0
	bmax=3*median(imaje[nz])
ENDIF

box_img = DOUBLE(imaje(box1[0]:box1[1],box1[2]:box1[3]))
good = WHERE(box_img GT 0)
IF good(0) NE -1 THEN box_med = MEDIAN(box_img(good)) ELSE box_med=median(imaje)
IF keyword_set(HIDE_PYLON) THEN BEGIN

	;IF hide_pylon EQ 1 THEN lim = 60 ELSE lim = hide_pylon
	pylon2 = where(imaje(pylon) LT box_med*0.95 OR imaje(pylon) GT box_med*1.2)
	pylval = box_med*0.97
	imaje(pylon(pylon2)) = pylval
	FXADDPAR,shdr,'HISTORY','Out of bound values in pylon area replaced with '+TRIM(STRING(pylval))
ENDIF

szim = SIZE(imaje)
horx = szim(1)
ver1 = 0
ver2 = szim(2)-1
IF cam NE 'EIT' THEN BEGIN
	;edge = ROUND(0.0025*horx)
	edge = 2
	imaje(0:edge-1,*)		=maskfill	; mask edge of  image
	imaje(horx-edge-1:horx-1,*)	=maskfill
	imaje(*,ver1:ver1+edge)		=maskfill
	imaje(*,ver2-edge:ver2)		=maskfill
	hist = 'Outer '+TRIM(STRING(edge))+' pixels of image masked before distortion correction.'
	print,hist
	FXADDPAR,shdr,'HISTORY',hist
ENDIF ELSE BEGIN
;	imaje[*,0:4] = median(imaje[horx-24:horx-1,5:10])
ENDELSE

IF keyword_set(DISTORT) THEN BEGIN
   IF hdr.detector EQ 'C2' THEN BEGIN
	imaje = c2_warp(temporary(imaje),hdr)    ; correct for distortion
	;c2wedge=wedge(imaje,1.0,0.976)		 ; correct for N-S wedge
	;imaje=imaje*c2wedge
   ENDIF
   IF hdr.detector EQ 'C3' THEN imaje = c3_warp(temporary(imaje),hdr)
   FXADDPAR,shdr,'HISTORY','Distortion correction applied: c2/c3_warp.pro'
ENDIF


IF KEYWORD_SET(LEE_FILT) THEN BEGIN
	wset,0 & tvscl,imaje<bmax>bmin

	print,'Doing LEEFILT'
	imaje = LEEFILT(temporary(imaje),5,3)
	print,'Done with LEEFILT.'
	wait,1
	tvscl,imaje<bmax>bmin
ENDIF

	;IF keyword_set(HIDE_PYLON) THEN BEGIN
	;	restore,'$imax/c3pylon.sav'	; contains variable 'pylon'
	;	cand = where(imaje(pylon) GT 1.04*fillcol OR imaje(pylon) LT 0.96*fillcol)
       	;	imaje(pylon(cand)) = fillcol
	;ENDIF
roll = -1*sroll 
IF keyword_set(ROLL) and abs(roll) GT 2 THEN BEGIN
	print,'%%MK_IMG: Rotating ',name+ext,roll,' degrees CW around ',sunxcen,sunycen
	imaje =rot(temporary(imaje),roll,1,sunxcen,sunycen,/pivot,/interp)
	FXADDPAR,shdr,'HISTORY','Corrected for roll of '+trim(string(roll))+' CCW'
	roll=0
ENDIF
FXADDPAR,shdr,'CROTA',roll,' degrees CCW'
FXADDPAR,shdr,'HISTORY','Roll angle derived from '+src1

WINDOW, 6, XSIZE=fhsize, YSIZE=fvsize, /PIXMAP	; FFV

IF keyword_set(MASK_OCC) or keyword_set(LG_MASK_OCC) or keyword_set(INMASK) or keyword_set(OUTMASK) THEN BEGIN
           tmp_img = imaje & tmp_img(*) = 0 
	   WSET,6
	   TV,tmp_img
        TVCIRCLE, r_occ_out,sunxcen,sunycen, /FILL, COLOR=1
        TVCIRCLE, r_occ, sunxcen, sunycen, /FILL, COLOR=2
	IF keyword_set(CIRC_WIDTH) THEN circle=circ_width ELSE circle=3
        TVCIRCLE, r_sun, sunxcen, sunycen, COLOR=3, THICK=circle
        tmp_img = TVRD()
        outer = WHERE(tmp_img EQ 0)
	suncir=where(tmp_img GE 3)
	occ = where(tmp_img EQ 2)
	IF NOT keyword_set(OUTMASK) THEN BEGIN
		IF (occ(0) NE -1) THEN imaje(occ) = maskfill
		cirval = MAX(imaje)
		
		IF (suncir(0) NE -1) THEN imaje(suncir) = cirval
	ENDIF
        IF NOT keyword_set(INMASK) and (outer(0) NE -1) THEN $
		imaje(outer) = maskfill
ENDIF

  IF keyword_set(COORDS) THEN imaje = imaje(img0_xy[0]:img0_xy[1],img0_xy[2]:img0_xy[3]) 
  ; ** imaje is 512x512 or 1024x1024 up to here **
  imaje = REBIN(imaje, hsize, vsize)

maxmin,imaje
print,'Using bmin =',bmin,'  bmax =',bmax

  IF keyword_set(DO_BYTSCL) THEN BEGIN
	imaje= BYTE(((imaje > bmin < bmax)-bmin)* (256-1)/ (bmax-bmin))
;	imaje= BYTE(((imaje > bmin < bmax)-bmin)* (!D.N_COLORS-1)/ (bmax-bmin))

	;img_med=median(imaje(nz))

	WINDOW, 6, XSIZE=hsize, YSIZE=vsize, /PIXMAP
	TV, imaje

	IF KEYWORD_SET(TIMES) THEN BEGIN 
		XYOUTS, 15*img_pan, 20*img_pan, label, /DEVICE, CHARSIZE=csize
	;	XYOUTS, 10, 10, cam+'  '+times, /DEVICE, CHARSIZE=csize
	ENDIF
	IF keyword_set(FNAME) THEN XYOUTS, hsize-10,10, hdr.filename, $
		/device, charsize=csize, alignment=1.0

	imaje = TVRD()
        IF keyword_set(LOGO) THEN imaje = add_lasco_logo(temporary(imaje))

      	win_index = !D.WINDOW
	IF not(keyword_set(NO_DISPLAY)) THEN BEGIN
		WSET, 0
		DEVICE, COPY = [0, 0, hsize, vsize, 0, 0, 6]	;, win_index]
	ENDIF
;stop
  ENDIF ELSE BEGIN
	IF not(keyword_set(NO_DISPLAY)) THEN BEGIN
		wset,0
		tvscl,imaje<bmax>bmin
	ENDIF
	imaje = float(imaje)
  ENDELSE
;stop
      yloc = yloc + 1

; ** copied from reduce_level_1.pro **

fxaddpar,shdr,'FILENAME',hdr.filename

FXADDPAR,shdr,'COMMENT','FITS coordinate for center of full image is (512.5,512.5).'
;FXADDPAR,shdr,'HISTORY',cmnver+', '+trim(string(xc))+', '+trim(string(yc))+', '+trim(string(r))+' Deg'
FXADDPAR,shdr,'CRVAL1',0
FXADDPAR,shdr,'CRVAL2',0
FXADDPAR,shdr,'CTYPE1','ARCSEC'
FXADDPAR,shdr,'CTYPE2','ARCSEC'
;platescl = GET_SEC_PIXEL(hdr)
;FXADDPAR,shdr,'HISTORY',cmnver
;utcdt=anytim2utc(tcr.date)
;newdt=utc2str(utcdt,/date_only)	; use dashes instead of slashes
;fxaddpar, shdr, 'DATE-OBS',newdt,' Corrected.'
;fxaddpar, shdr, 'TIME-OBS',tcr.time,' Corrected.'
fxaddpar,shdr,'COMMENT','Time of obs may be off by seconds (is uncorrected)'
;FXADDPAR, shdr, 'DATE_OBS',newdt+'t'+tcr.time
FXADDPAR, shdr, 'DATE_OBS',date_obs+'t'+time_obs

;rsun = get_solar_radius(hdr)	
fxaddpar, shdr, 'RSUN',asolr,' Arcsec'
;fxaddpar, shdr, 'NMISSING',nmissing,' Number of missing blocks.'
;printf,lulog,'NMISSING = ',string(nmissing)

;FXADDPAR, shdr, 'MISSLIST',missing_string
;FXADDPAR, shdr, 'BUNIT','MSB',' Mean Solar Brightness'
fxaddpar, shdr,'BLANK',0.
; ****

return, imaje
END
