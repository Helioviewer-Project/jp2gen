;
; hv_lasco_wget_monthly
;
; adapted from the SSW routine lasco_wget_monthly
;
pro hv_lasco_wget_monthly, forceall=forceall, debug=debug,details_file = details_file
;
;+
;   Name: lasco_wget_monthly
;
;   Purpose: nrl LASCO dbase -> SSWDB ($SSWDB/soho/lasco/monthly)
;
;   History
;      Circa 1-jan-2002 - S.L.Freeland 
;      18-mar-3003 - S.L.Freeland - do a chmod on $SSWDB/soho/lasco
;                    due to change in default nascom/eaf 'umask' settings
;	9-oct-2003 - N.Rich - Include rolled/ directory
;

;
;
;
  IF NOT(KEYWORD_SET(details_file)) THEN BEGIN
     details_file = 'hvs_default_lasco_c2'
  ENDIF
  info = CALL_FUNCTION(details_file)
  alternate_backgrounds = info.alternate_backgrounds

  debug=keyword_set(debug)
  forceall=keyword_set(forceall)

  outdir = [alternate_backgrounds,alternate_backgrounds + 'rolled/']
;outdir=[concat_dir('$SSWDB','soho/lasco/monthly'),concat_dir('$SSWDB','soho/lasco/monthly/rolled')]
  geturl=['http://lasco-www.nrl.navy.mil/retrieve/monthly/','http://lasco-www.nrl.navy.mil/retrieve/monthly/rolled/']
  wget=concat_dir('$SSW','gen/wget/tru64/wget_osf')

  FOR j=0,1 DO BEGIN
     cd,outdir[j]
     index=concat_dir(outdir[j],'index.html')
     ssw_file_delete,index

     spawn,[wget,geturl[j]],/noshell

     if not file_exist(index) then begin 
        box_message,'Cannot find '+index
        goto, next
     endif

     data=rd_tfile(index)

     remotef=strarrcompress(strextract(data,'<A HREF="','">'))
	; remotef=(strextract(remotef,'"'))(1:*)

     local=concat_dir(outdir[j],remotef)

     ncnt=n_elements(local)

     if forceall then need=lindgen(ncnt) else $
        need=where(1-file_exist(local),ncnt)
     for i=0,ncnt-1 do begin 
        spawn,[wget,concat_dir(geturl[j],remotef(need(i)))],/noshell
                                ;stop,'i'
     endfor

     oldindex=file_list(outdir[j],'index.html.*')
     if oldindex(0) ne '' then begin 
        oldss=where(strlen( ssw_strsplit(oldindex,'/',/last,/tail)) lt 15,ocnt)
        if ocnt gt 0 then file_delete, oldindex(oldss)
     endif
     
     ssw_make_html_index,outdir[j]
     
                                ; chmod
     chmod_cmd=['chmod','-R','o+r,g+r',outdir[j]]
     spawn,chmod_cmd,/noshell
     if debug then stop
     next:
  ENDFOR


end
