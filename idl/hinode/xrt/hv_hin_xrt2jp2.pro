

FUNCTION hvs_hinode_xrt, struc_header  
  ;;+ 
  ;; Purpose:
  ;;     Create the XRT details structure with instrument information
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from  C.E.Fischer's code. 
  ;;-
  ;;  


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
  b.details[0].bit_rate = [4.0,0.1] ; REQUIRED
  b.details[0].dataScalingType = 3  ; 0 - linear, 1 - sqrt, 3 - log10

            
 RETURN,b
 
END


PRO HV_HIN_XRT2JP2_specific,img, struc_header, dir, file, outdir=outdir, err=err
  
  ;;+ 
  ;; Purpose:
  ;;     Call hvs_hinode_xrt to create XRT specific details structure, then
  ;;     call the instrument and mission indipendent hv_hvs2jpt to create jpg2000
  ;;     images. Oslo SDC Archive routines call this procedure directly
  ;;     without calling the wrapper routines first.
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from C.E.Fischer's code. Minor
  ;;                                 additions and changes to the code.
  ;; - 
  
  err = ''
  IF struc_header.naxis ne 2 THEN BEGIN
     err = 'NAXIS HAS TO BE 2!  SKIPPING FILE '+file+'. '
     return
  ENDIF
  
  ;; hv_check_outdir is short circuited when the OSDCS environment varible is set:
  hv_check_outdir, outdir=outdir
   
  comment='HINODE XRT FILE'
  measurement = strcompress('FW1_'+struc_header.EC_FW1_+'_FW2_'+struc_header.EC_FW2_,/remove_all) 
  
  ; Create details structure with observer and instruments information
  info = hvs_hinode_xrt(struc_header) 
  
  hv_hvs2jp2, img, struc_header, dir, file, comment, measurement, info
  
  
END


PRO hv_hin_xrt2jp2, files, outdir=outdir, dir=dir
  
; +
;PRO 
; 
;
; Name: hv_hin_xrt2jp2
;
; Purpose: Convert Level1 Hinode XRT images into JPEG2000. hv_hin_xrt2jp2 is
;          now a wrapper to the instrument independent procedure
;          idl/hinode/hv_hin_instr2jp2. hv_hin_instr2jp2 runs hv_check_outdir
;          and edits the fits header before calling the SOT/FG specific
;          routine hv_hin_fg2jp2_specific which is included in this
;          file. 
;          NOTE: the object oriented programs that create the Oslo SDC archive 
;          images call hv_hin_fg2jp2_specific directly. hv_hin_fg2jp2_specific calls
;          the instrument independent procedure hv_hvs2jp2 which creates the
;          hvs structure that is passed to the instrument and mission
;          independent hv_make_jp2, which is the routine that actually creates
;          the jpg2000 images. Puh!
;
; Input Parmeters:
;   files - list of one or more XRT 2D fitsfiles. Either full path plus file
;   name, or just the filename if DIR keyword is set.
; 
; OPTIONAL Input Parameters:
;   DIR    - directory of the input fitsfile ; if not set current directory is 
;            assumed
;   OUTDIR - path to save the JPEG2000 files, otherwise the directory given
;            in hv_writtenby is used
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
; Calls : idl/hinode/hv_hin_instr2jp2 and (included in this program) hvs_hinode_xrt
;         and HV_HIN_XRT2JP2_specific, and several IDL ASTRONOMY LIBRARY programs
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
  hv_hin_instr2jp2,'xrt',files,outdir=outdir,dir=dir
END
