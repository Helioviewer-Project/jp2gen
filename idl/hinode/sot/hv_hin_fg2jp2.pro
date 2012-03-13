
;PRO 
; 
;
; Name: hv_hin_fg2jp2
;
; Purpose: Convert Level1 Hinode SOT filtergrams into JPEG2000.
;          The fits header is converted into a header structure.
;          It uses the hv_make_jp2.pro file to create the JPEGs
;
; Input Parmeters:
;   files - list of one or more SOT NFI or BF 2D fitfiles  (x,y)
; 
; OPTIONAL Input Parameters:
;   DIR    - directory of the source file ; if not set will be current directory
;   OUTDIR    - path to save the JPEG2000 files, otherwise the directory given in hv_writtenby is used
;
; 
; Output Paramters:
; JPEG2000 file for each NFI, BF image with metadata included
;
; Keyword Parameters:
; 
; Calling Sequence:
; IDL> hv_hin_fg2jp2,<files>,outdir=<save directory>
;
; Calls :     hv_hin_instr2jp2 and (included in this program) hvs_hinode_fg,
;             replstr, hv_hin_fg_headerreplace, HV_HIN_FG2JP2_specific and 
;             several IDL ASTRONOMY LIBRARY programs
; 
; 
; Side Effects:
;
; Restrictions:
;
; History: 22.08.2011 first version C.E.Fischer (cfischer@rssd.esa.int)
;          15.11.2011 Terje Fredvik re-written version. Contents of this file are mostly bits and pieces
;          extracted from Fisher's original code.
    


FUNCTION replstr,tagname,ori,new ;REPLACE THE STRING 'ORI' WITH 'NEW' IN THE GIVEN STRING TAGNAME 
  for ind=0,strlen(tagname)-1 do begin
     t_w=strpos(tagname,ori)
     if t_w ne -1 then strput,tagname,new,t_w
  endfor
  return,tagname
END


PRO hv_hin_fg_headerreplace, struc_header
  IF size(struc_header,/tname) NE 'STRUCT' THEN message,'Input parameter must be an SOT header structure'
     
                                  ;REPLACE SOME STRINGS THAT OTHERWISE CAUSE PROBLEMS IN THE DIRECTORY CREATION 
  struc_header.wave=replstr(struc_header.wave,' ','_')
  struc_header.instrume=replstr(struc_header.instrume,'/','_')
  struc_header.obs_type=replstr(struc_header.obs_type,'(','_')
  struc_header.obs_type=replstr(struc_header.obs_type,')','_')
  struc_header.obs_type=strcompress(struc_header.obs_type,/remove_all)
  
END


FUNCTION hvs_hinode_fg, struc_header          ;CREATE THE DETAILS STRUCTURE WITH INSTRUMENT INFORMATION

  d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01], dataScalingType: 0}
 

  b = {details:d,$  ; REQUIRED
       observatory: struc_header.telescop,$
      instrument:'SOT',$
      detector:struc_header.instrume,$
      nickname: struc_header.obs_type,$
      hvs_details_filename: 'hvs_hinode_fg.pro',$
      hvs_details_filename_version: '1.0',$
       parent_out:'~/tmp/'}               ; REQUIRED
       
       
  b.details[0].measurement = struc_header.wave; REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED
 ; b.details[0].dataMin = 0.1;0.25;3.0
 ; b.details[0].dataMax = 30.0;250.0;50.0
  b.details[0].dataScalingType = 0 
 ; b.details[0].dataExptime = 
  ;b.details[0].gamma = 1.0
 ; b.details[0].fixedImageValue = [0,500000]
            
 RETURN,b
 
END


PRO HV_HIN_FG2JP2_specific, img, struc_header, dir, file, outdir=outdir, err=err
  err = ''
  IF struc_header.naxis ne 2 THEN err = 'NAXIS HAS TO BE 2!  SKIPPING FILE '+file+'. '
  IF struc_header.obs_type ne 'FG (simple)' THEN err += 'NOT AN FG (SIMPLE) FILE! SKIPPING FILE '+file
  IF err NE '' THEN return
  
  hv_check_outdir, outdir=outdir
  
  hv_hin_fg_headerreplace, struc_header
   
  comment='HINODE FG FILE'  
  measurement = struc_header.wave
  info = hvs_hinode_fg(struc_header) ; CREATE DETAILS STRUCTURE WITH OBSERVER AND INSTRUMENTS INFORMATION
  
  hv_hvs2jp2, img, struc_header, dir, file, comment, struc_header.wave, info
  
END


PRO hv_hin_fg2jp2, files, outdir=outdir, dir=dir
  hv_hin_instr2jp2,'fg',files,outdir=outdir,dir=dir
END
