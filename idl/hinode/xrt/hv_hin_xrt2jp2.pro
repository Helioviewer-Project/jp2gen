
;PRO 
; 
;
; Name: hv_hin_xrt2jp2
;
; Purpose: Convert Level1 Hinode XRT images into JPEG2000.
;          The fits header is converted into a header structure.
;          It uses the hv_make_jp2.pro file to create the JPEGs
;
; Input Parmeters:
;   files - list of one or more XRT 2D fitfiles  (x,y) 
; 
; OPTIONAL Input Parameters:
;   DIR    - directory of the input fitsfile ; if not set current directory is assumed
;   OUTDIR    - path to save the JPEG2000 files, otherwise the directory given in hv_writtenby is used
;
; 
; Output Paramters:
; JPEG2000 file for each XRT image with metadata included
;
; Keyword Parameters:
; 
; Calling Sequence:
; IDL> hv_hin_xrt2jp2,<files>,outdir=<save directory>
;
; Calls : hv_hin_instr2jp2 and (included in this program) hvs_hinode_xrt
;         and HV_HIN_XRT2JP2_specific, and several IDL ASTRONOMY LIBRARY programs
; 
; 
; Side Effects:
;
; Restrictions:
;
; History: 22.08.2011 first version C.E.Fischer (cfischer@rssd.esa.int)
;          08.12.2011 SDC version Terje Fredvik. Instead of a list of file
;          names, HV_HIN_FG2JP2 now takes an image and a header structure as inputs, in addition to path and
;          filename of file that was read in order to create image and
;          header. The wrapper hv_hin_instr2jp2_obj or hv_hin_instr2jp2_files 

FUNCTION hvs_hinode_xrt, struc_header         ;CREATE THE DETAILS STRUCTURE WITH INSTRUMENT INFORMATION

d = {measurement: "", n_levels: 8, n_layers: 8, idl_bitdepth: 8, bit_rate: [0.5,0.01], dataScalingType: 0}

;
; Full description
;
  b = {details:d,$  ; REQUIRED
       observatory: struc_header.telescop,$
      instrument:'XRT',$
      detector:struc_header.instrume,$
      nickname: struc_header.instrume,$
      hvs_details_filename: 'hvs_hinode_xrt.pro',$
      hvs_details_filename_version: '1.0',$
       parent_out:'~/tmp/'}               ; REQUIRED
       
       
  b.details[0].measurement = strcompress('FW1_'+struc_header.EC_FW1_+'_FW2_'+struc_header.EC_FW2_,/remove_all); REQUIRED
  b.details[0].n_levels = 8 ; REQUIRED
  b.details[0].n_layers = 8 ; REQUIRED
  b.details[0].idl_bitdepth = 8 ; REQUIRED
  b.details[0].bit_rate = [0.5,0.01] ; REQUIRED
 ; b.details[0].dataMin = 0.1;0.25;3.0
 ; b.details[0].dataMax = 30.0;250.0;50.0
 b.details[0].dataScalingType = 3; 0 - linear, 1 - sqrt, 3 - log10
 ; b.details[0].dataExptime = 
  ;b.details[0].gamma = 1.0
 ; b.details[0].fixedImageValue = [0,500000]
            
 RETURN,b
 
END


PRO HV_HIN_XRT2JP2_specific,img, struc_header, dir, file, outdir=outdir, err=err
  err = ''
  IF struc_header.naxis ne 2 THEN BEGIN
     err = 'NAXIS HAS TO BE 2!  SKIPPING FILE '+file+'. '
     return
  ENDIF
  
  hv_check_outdir, outdir=outdir 
  
  comment='HINODE XRT FILE'
  measurement = strcompress('FW1_'+struc_header.EC_FW1_+'_FW2_'+struc_header.EC_FW2_,/remove_all) 
  info = hvs_hinode_xrt(struc_header) ; CREATE DETAILS STRUCTURE WITH OBSERVER AND INSTRUMENTS INFORMATION
    
  hv_hvs2jp2, img, struc_header, dir, file, comment, measurement, info
  
  
END


PRO hv_hin_xrt2jp2, files, outdir=outdir, dir=dir
  hv_hin_instr2jp2,'xrt',files,outdir=outdir,dir=dir
END
