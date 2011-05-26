function hv_scc_bytscl,img,hdr, DISPLAY=display, SILENT=silent, MINMAX=minmax
;+
; $Id: scc_bytscl.pro,v 1.11 2010/12/22 23:47:52 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : scc_bytscl.pro
;               
; Purpose   : returns byte scaled SECCHI image 
;               
; Explanation: The program returns a byte scaled image for display or
;              to print to a image file.
;
; Use       : IDL> img = scc_bytscl(im, hdr)
;    
; Inputs    : im - image with large dynamic range
;             hdr -image header (FITS or SECCHI header structure)
;               
; Outputs   : img - image scaled between 0 and 256
;
; Keyowrds: 	/DISPLAY    display a 512x512 version of image
;   	    	MINMAX=     Returns min, max used to bytscl
;
; Procedure : For EUVI image the program takes the log base 10 of the
;             image before bytscaling.
;
; Category    : Admistration
;               
; Prev. Hist. : None.
;
; Written     : Robin C Colaninno NRL/GMU Jan 2007
;               
; $Log: scc_bytscl.pro,v $
; Revision 1.11  2010/12/22 23:47:52  nathan
; change default min max
;
; Revision 1.10  2010/11/17 23:32:36  nathan
; add MINMAX=; use IF instead of CASE stmt
;
; Revision 1.9  2008/01/24 17:37:10  nathan
; allow subfields
;
; Revision 1.8  2007/12/19 21:35:01  nathan
; added /SILENT and revision logging
;
; Revision 1.3  2007/04/04 15:27:25  colaninn
;
; Revision 1.2  2007/02/26 19:07:41  colaninn
; changed HI bytscl
;
; Revision 1.1  2007/01/18 21:36:32  colaninn
; created
;
;-

IF(DATATYPE(hdr) NE 'STC') THEN hdr=SCC_FITSHDR2STRUCT(hdr)
IF ~strmatch(TAG_NAMES(hdr,/STRUCTURE_NAME),'SECCHI_HDR_STRUCT*') THEN $
MESSAGE, 'ONLY SECCHI HEADER STRUCTURE ALLOWED'

im = img
mx = where(im EQ max(im),nmx)
md = median(im)
tel=hdr.detector
IF tel EQ 'EUVI' or tel EQ 'EIT' or tel EQ 'AIA' THEN BEGIN
	zero = where(im LE 0,znum)
	IF znum NE 0 THEN im[zero]=1
	im = alog10(im)
	IF hdr.exptime NE 1 and ~keyword_set(SILENT) THEN BEGIN
	    print,''
	    message,'CAUTION: min/max optimized for DN/s (EXPTIME='+trim(hdr.exptime)+')',/info
	    wait,3
	ENDIF
	
	CASE hdr.WAVELNTH OF
    	    171: minmax=[-0.2,3.7]  ;0,3.75)
    	    195: minmax=[-0.8,3.4]  ;-1,3.9)
    	    284: minmax=[-0.7,2.7]  ;0,2.5)
    	    304: minmax=[-1.0,4.0]  ;-0.5,4)
	ENDCASE
ENDIF ELSE $
IF tel EQ 'COR1' THEN minmax=[0,hdr.datap98] ELSE $
IF tel EQ 'COR2' THEN minmax=[0,hdr.datap98] ELSE $
IF tel EQ 'HI1' THEN minmax=[0,hdr.datap98] ELSE $
IF tel EQ 'HI2' THEN minmax=[0,hdr.datap98] ELSE BEGIN
    message,'Unrecognized telescope.',/info
    minmax=[0.9*md,1.2*md]
ENDELSE

im1 = bytscl(im,minmax[0],minmax[1])

IF keyword_set(DISPLAY) THEN BEGIN
    qysz=512*float(hdr.naxis2)/hdr.naxis1
    window,1,xsiz=512,ysiz=qysz
    tv,rebin(im1,512,qysz)
    wait,3
ENDIF
IF nmx NE 0 THEN im1[mx] = 255

RETURN,im1
END
