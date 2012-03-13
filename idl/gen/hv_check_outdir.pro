PRO hv_check_outdir, outdir=outdir, err=err
  ;;+ 
  ;; Purpose:
  ;;    Check that outdir and hv_writtenby exsit
  ;;
  ;; Modification History: 
  ;;       2011.12.08 Terje Fredvik: Extracted from  C.E.Fischer's code. 
  ;;-
  ;; 
  err = ''
  
  if keyword_set(outdir) eq 1 then begin ; CHECK IF OUTDIR IS SET. IF YES, FIND THE HV_WRRITTENBY FILE AND CHANGE THE DIRECTORY IN THE FILE.
     
     
     IF file_test(outdir) eq 0 then  box_message,'OUTDIRECTORY DOES NOT EXIST. WILL CREATE IT!' ;CHECK IF DIRECTORY EXISTS
     
     if strmid(outdir,strlen(outdir)-1) ne path_sep() then outdir=outdir+path_sep() ;MAKE SURE PATH SEPERATOR IS AT THE END OF STRING
     
     
     FindPro, 'hv_writtenby.pro', NoPrint=1, DirList=DirList ;CHECK IF HV_WRITTENBY>PRO EXISTS
     if dirlist[0] eq '' then err = 'CAN NOT FIND HV_WRITTENBY. EXITING...'
     
     
     if n_elements(dirlist) gt 1 then box_message,strcompress('YOU HAVE TWO HV_WRITTENBY IN YOUR PATH, SELECTING THE ONE IN '+dirlist(0))
     
     
     wbfile=rd_tfile(dirlist(0)+path_sep()+'hv_writtenby.pro') ; READ IN STRING ARRAY
     thisstr=strmatch(wbfile,'*jp2gen_write*:*')               ; FIND OUTDIR SPECIFICATION
     wbfile(where(thisstr eq 1))=strcompress("jp2gen_write: '"+outdir+"' , $")
     openw,wflun,dirlist(0)+'/hv_writtenby.pro',/get_lun
     for i=0,n_elements(wbfile)-1 do begin
        printf,wflun,wbfile(i)
     endfor
     free_lun,wflun
     close,wflun
  endif 
  
  
END
       
  

   
