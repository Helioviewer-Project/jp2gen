
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
;   SOT_XRT2dfiles - list of one or more XRT 2D fitfiles  (x,y) 
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
; Calls :     replstr and hvs_hinode_fg included in this program, and 
;             several IDL ASTRONOMY LIBRARY programs
; 
; 
; Side Effects:
;
; Restrictions:
;
; History: 22.08.2011 first version C.E.Fischer (cfischer@rssd.esa.int)

FUNCTION replstr,tagname,ori,new  ;REPLACE THE STRING 'ORI' WITH 'NEW' IN THE GIVEN STRING TAGNAME 
  for ind=0,strlen(tagname)-1 do begin
    t_w=strpos(tagname,ori)
    if t_w ne -1 then strput,tagname,new,t_w
  endfor
  return,tagname
END



FUNCTION hvs_hinode_xrt         ;CREATE THE DETAILS STRUCTURE WITH INSTRUMENT INFORMATION
common inf_coms,struc_header
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

pro HV_HIN_XRT2JP2,XRT_2dfiles,outdir=outdir,dir=dir
common inf_coms,struc_header

     if dir_exist(outdir) eq 0 then  box_message,'OUTDIRECTORY DOES NOT EXIST. WILL CREATE IT!'  ;CHECK IF DIRECTORY EXISTS
    
     if strmid(outdir,strlen(outdir)-1) ne path_sep() then outdir=outdir+path_sep() ;MAKE SURE PATH SEPERATOR IS AT THE END OF STRING  
       
     if keyword_set(outdir) eq 1 then begin   ; CHECK IF OUTDIR IS SET. IF YES, FIND THE HV_WRRITTENBY FILE AND CHANGE THE DIRECTORY IN THE FILE.
       
        FindPro, 'hv_writtenby.pro', NoPrint=1, DirList=DirList;CHECK IF HV_WRITTENBY>PRO EXISTS
        if dirlist eq '' then begin
         box_message,'CAN NOT FIND HV_WRITTENBY. EXITING...'
         goto,JUMP2
        endif
        
             
        if n_elements(dirlist) gt 1 then box_message,strcompress('YOU HAVE TWO HV_WRITTENBY IN YOUR PATH, SELECTING THE ONE IN '+dirlist(0))
      
        
        wbfile=rd_tfile(dirlist(0)+path_sep()+'hv_writtenby.pro') ; READ IN STRING ARRAY
        thisstr=strmatch(wbfile,'*jp2gen_write*:*')     ; FIND OUTDIR SPECIFICATION
        wbfile(where(thisstr eq 1))=strcompress("jp2gen_write: '"+outdir+"' , $")
        openw,wflun,dirlist(0)+'/hv_writtenby.pro',/get_lun
           for i=0,n_elements(wbfile)-1 do begin
              printf,wflun,wbfile(i)
           endfor
        free_lun,wflun
        close,wflun
     endif 


;SET SOURCE DIRECTORY IF NOT GIVEN
    
     if keyword_set(dir) eq 0 then dir=''
     if strmid(dir,strlen(dir)-1) ne path_sep() and dir ne '' then dir=dir+path_sep() ;MAKE SURE PATH SEPERATOR IS AT THE END OF STRING  
     
     if n_elements(XRT_2dfiles) lt 1 then box_message,'NO FILES GIVEN!'
;;LOOP through files, creating a jp2000 for each file
     for ff=0,n_elements(XRT_2dfiles)-1 do begin
         
         fitsname=dir+XRT_2dfiles(ff)
       
         if file_exist(fitsname) eq 0 then begin
           box_message,'CAN NOT FIND FITSFILE '+XRT_2dfiles(ff)
           goto,jump1
         endif
         img=readfits(fitsname,fitshead)
         struc_header=FITSHEAD2STRUCT(fitshead);get file 


        ;;CHECK IF 2D FILE
        if struc_header.naxis ne 2 then begin 
          box_message,strcompress('NAXIS HAS TO BE 2!  SKIPPING FILE '+fitsname)
          goto, jump1
        endif

        comment='HINODE XRT FILE'


        info=CALL_FUNCTION('hvs_hinode_xrt')       ; CREATE DETAILS STRUCTURE WITH OBSERVER AND INSTRUMENTS INFORMATION
        
        tobs = HV_PARSE_CCSDS(struc_header.date_obs)

        hvsi = {  dir:dir, $ ; the directory where the source FITS file is stored,default is current dir
          fitsname:fitsname, $ ; the name of the FITS file
          header: struc_header, $ ; the ENTIRE FITS header as a structure - use FITSHEAD2STRUCT
          comment: comment, $ ; a string that contains any further information 
          measurement:strcompress('FW1_'+struc_header.EC_FW1_+'_FW2_'+struc_header.EC_FW2_,/remove_all),$ ; the particular measurement of this FITS file
           yy:tobs.yy,$
           mm:tobs.mm,$
           dd:tobs.dd,$
           hh:tobs.hh,$
           mmm:tobs.mmm,$
           ss:tobs.ss,$
           milli:tobs.milli,$
           details:info }

        hvs = {img:img, $ ; a 2-d numerical array that is the image you want to write
         hvsi:hvsi $ ; a structure containing the relevant information about img
        }

     
       HV_MAKE_JP2,hvs    ; CONVERT IMAGES TO JP2000
     
     
     JUMP1:         ;GO TO NEXT FILE
   endfor  
 JUMP2:              ;EXIT PROGRAM
END
 