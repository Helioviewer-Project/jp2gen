
FUNCTION replstr,tagname,ori,new 
  ;;+ 
  ;; Purpose: 
  ;;     Replace the string 'ori' with 'new' in the given string tagname 
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from C.E.Fischer's code. 
  ;;-

  for ind=0,strlen(tagname)-1 do begin
     t_w=strpos(tagname,ori)
     if t_w ne -1 then strput,tagname,new,t_w
  endfor
  return,tagname
END


PRO hv_hin_fg_headerreplace, struc_header
  ;;+ 
  ;; Purpose: 
  ;;       Replace some strings that otherwise cause problems in the
  ;;       directory creation
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from C.E.Fischer's code. 
  ;;-
  ;;  
  IF size(struc_header,/tname) NE 'STRUCT' THEN message,'Input parameter must be an SOT header structure'
     
                                 
  struc_header.wave=replstr(struc_header.wave,' ','_')
  struc_header.instrume=replstr(struc_header.instrume,'/','_')
  struc_header.obs_type=replstr(struc_header.obs_type,'(','_')
  struc_header.obs_type=replstr(struc_header.obs_type,')','_')
  struc_header.obs_type=strcompress(struc_header.obs_type,/remove_all)
  
END


FUNCTION hvs_hinode_fg, struc_header       
  ;;+ 
  ;; Purpose:
  ;;     Create the SOT/FG details structure with instrument information
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from C.E.Fischer's code. 
  ;;-
  ;;    

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
  ;;+ 
  ;; Purpose:
  ;;     Call hvs_hinode_fg to create SOT/FG specific details structure, then
  ;;     call the instrument and mission indipendent hv_hvs2jpt to create jpg2000
  ;;     images. Oslo SDC Archive routines call this procedure directly
  ;;     without calling the wrapper routines first.
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from C.E.Fischer's code. Minor
  ;;                                 additions and changes to the code.  
  ;; - 
  
  
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
  ; +
;PRO 
; 
;
; Name: hv_hin_fg2jp2
;
; Purpose: Convert Level1 Hinode SOT/FG images into JPEG2000. hv_hin_fg2jp2 is
;          now a wrapper to the instrument independent procedure
;          idl/hinode/hv_hin_instr2jp2. hv_hin_instr2jp2 runs hv_check_outdir
;          and edits the fits header before calling the SOT/FG specific
;          routine hv_hin_fg2jp2_specific which is included in this file. The
;          object oriented programs that create the Oslo SDC archive images
;          call hv_hin_fg2jp2_specific directly. hv_hin_fg2jp2_specific calls
;          the instrument independent procedure hv_hvs2jp2 which creates the
;          hvs structure that is passed to the instrument and mission
;          independent hv_make_jp2 which is the routine that actually creates
;          the jpg2000 images.
;
; Input Parmeters:
;   files - list of one or more SOT/FG 2D fitsfiles  (x,y) 
; 
; OPTIONAL Input Parameters:
;   DIR    - directory of the input fitsfile ; if not set current directory is 
;            assumed
;   OUTDIR - path to save the JPEG2000 files, otherwise the directory given
;            in hv_writtenby is used
;
; 
; Output Paramters:
; JPEG2000 file for each FG image with metadata included
;
; Keyword Parameters:
; 
; Calling Sequence:
; IDL> hv_hin_fg2jp2,<files>,outdir=<save directory>
;
; Calls : idl/hinode/hv_hin_instr2jp2 and (included in this program) hvs_hinode_fg
;         and HV_HIN_FG2JP2_specific, and several IDL ASTRONOMY LIBRARY programs
; 
; 
; Side Effects:
;
; Restrictions:
;
; History: 22.08.2011 C.E.Fischer: First version (cfischer@rssd.esa.int) 
;          2011.12.08 Terje Fredvik: Re-organized C.E.Fischer's code, see
;                                    Purpose in the doc header for new code
;                                    layout/workflow.
;-
;
  hv_hin_instr2jp2,'fg',files,outdir=outdir,dir=dir
END
