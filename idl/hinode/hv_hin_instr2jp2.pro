;PRO 
; 
;
; Name: hv_hin_fg2jp2
;
; Purpose: Convert a Level1 Hinode SOT filtergram or Hinode XRT file 
;          into JPEG2000.
;          The fits header is converted into a header structure.
;          It uses the hv_make_jp2.pro file to create the JPEGs
;
; Input Parmeters:
;   file - an XRT, SOT NFI or BF 2D fitfiles  (x,y)
; 
; OPTIONAL Input Parameters:
;   DIR    - directory of the source file ; if not set will be current directory
;   OUTDIR    - path to save the JPEG2000 files, otherwise the directory given in hv_writtenby is used
;
; 
; Output Paramters:
; JPEG2000 file for each XRT, NFI, BF image with metadata included
;
; Keyword Parameters:
; 
; Calling Sequence:
; IDL> hv_hin_instr2jp2,<file>,outdir=<save directory>
;
; Calls :     
; 
; 
; Side Effects:
;
; Restrictions:
;
; History: 22.08.2011 first version C.E.Fischer (cfischer@rssd.esa.int)
;          16.12.2011 Terje Fredvik, re-written, instrument
;          independent version. Contents of this file are mostly bits and pieces
;          extracted from Fisher's original code.
;          05.03.2012 Terje Fredvik, put in Catherine's DSUN_OBS fix 


PRO HV_HIN_INSTR2JP2, instr, files,outdir=outdir,dir=dir,  img=img, struc_header=struc_header, $
                       fitsname=fitsname, err=err
  err = ''
  
  hv_check_outdir, outdir=outdir, err=err
  IF err NE '' THEN message, err
  
  ;CHECK IF THERE ARE FILES
  IF n_elements(files) EQ 0 THEN message, 'No files given!'
  
  FOR i=0,n_elements(files)-1 DO BEGIN 
     IF file_test(files[i]) THEN BEGIN 
                                ;SET SOURCE DIRECTORY IF NOT GIVEN
        if keyword_set(dir) eq 0 then dir=''
        if strmid(dir,strlen(dir)-1) ne path_sep() and dir ne '' then dir=dir+path_sep() ;MAKE SURE PATH SEPERATOR IS AT THE END OF STRING 
          
        fitsname = dir + files[i]
        if file_test(fitsname) eq 0 then return
        
        ;; The following is not a good idea: should use instrument specific 
        ;; read and calibration routines! Or call the mk_jpg2000 method of a
        ;; hinobs object.
        img=readfits(fitsname,fitshead)
        
        ;;get observation time
        obs_date=FXPAR(fitshead,'DATE_OBS')
        
        ;; get distance in AU
        out=GET_SUN(obs_date,dist=dsun_obs)
        
        ;; convert to meters
        dsun_obs=dsun_obs*149597870700
        
        ;; header dsun_obs is added
        FXADDPAR,fitshead,'DSUN_OBS',dsun_obs
        
        struc_header=FITSHEAD2STRUCT(fitshead) ;get file 
        
        call_procedure,'hv_hin_'+instr+'2jp2_specific', img, struc_header, dir, fitsname,$
                       outdir=outdir, err=err
        
        IF err NE '' THEN message, err,/info
        
     ENDIF ELSE message, 'File '+files[i] + ' not found!',/info
    
  ENDFOR
  
END
 
