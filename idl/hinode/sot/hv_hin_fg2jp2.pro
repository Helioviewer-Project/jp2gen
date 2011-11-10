
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
;   SOT_FG2dfiles - list of one or more SOT NFI or BF 2D fitfiles  (x,y)
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


FUNCTION hvs_hinode_fg          ;CREATE THE DETAILS STRUCTURE WITH INSTRUMENT INFORMATION
common inf_coms,struc_header
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

PRO HV_HIN_FG2JP2,SOT_FG2dfiles,outdir=outdir,dir=dir
common inf_coms,struc_header
      

     if keyword_set(outdir) eq 1 then begin   ; CHECK IF OUTDIR IS SET. IF YES, FIND THE HV_WRRITTENBY FILE AND CHANGE THE DIRECTORY IN THE FILE.
     
     
        if dir_exist(outdir) eq 0 then  box_message,'OUTDIRECTORY DOES NOT EXIST. WILL CREATE IT!'  ;CHECK IF DIRECTORY EXISTS
       
        if strmid(outdir,strlen(outdir)-1) ne path_sep() then outdir=outdir+path_sep() ;MAKE SURE PATH SEPERATOR IS AT THE END OF STRING
        
      
        FindPro, 'hv_writtenby.pro', NoPrint=1, DirList=DirList ;CHECK IF HV_WRITTENBY>PRO EXISTS
        if dirlist[0] eq '' then begin
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




;CHECK IF THERE ARE FILES
   if n_elements(SOT_FG2dfiles) lt 1 then box_message,'NO FILES GIVEN!'
;;LOOP through files, creating a jp2000 for each file
   for ff=0,n_elements(SOT_FG2dfiles)-1 do begin
     
      fitsname=dir+SOT_FG2dfiles(ff)
      if file_exist(fitsname) eq 0 then begin
           box_message,'CAN NOT FIND FITSFILE '+SOT_FG2dfiles(ff)
           goto,jump1
      endif
         
     img=readfits(fitsname,fitshead)
     struc_header=FITSHEAD2STRUCT(fitshead);get file 
      
      
      ;CHECK IF FG SIMPLE
      if struc_header.obs_type ne 'FG (simple)' then begin 
        box_message,strcompress('NOT AN FG (SIMPLE) FILE! SKIPPING FILE '+fitsname)
        goto, JUMP1
      endif
     ;CHECK IF 2D FILE
      if struc_header.naxis ne 2 then begin 
        box_message,strcompress('NAXIS HAS TO BE 2!  SKIPPING FILE '+fitsname)
        goto, JUMP1
      endif
    
      ;REPLACE SOME STRINGS THAT OTHERWISE CAUSE PROBLEMS IN THE DIRECTORY CREATION 
      struc_header.wave=replstr(struc_header.wave,' ','_')
      struc_header.instrume=replstr(struc_header.instrume,'/','_')
      struc_header.obs_type=replstr(struc_header.obs_type,'(','_')
      struc_header.obs_type=replstr(struc_header.obs_type,')','_')
      struc_header.obs_type=strcompress(struc_header.obs_type,/remove_all)


      comment='HINODE FG FILE'


      info=CALL_FUNCTION('hvs_hinode_fg')    ; CREATE DETAILS STRUCTURE WITH OBSERVER AND INSTRUMENTS INFORMATION
      
      tobs = HV_PARSE_CCSDS(struc_header.date_obs)

      hvsi = {  dir:dir, $ ; the directory where the source FITS file is stored,default is current dir
          fitsname:fitsname, $ ; the name of the FITS file
          header: struc_header, $ ; the ENTIRE FITS header as a structure - use FITSHEAD2STRUCT
          comment: comment, $ ; a string that contains any further information 
          measurement:struc_header.wave,$ ; the particular measurement of this FITS file
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
 