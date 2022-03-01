;
; 2009/04/07 JI, original
; 2009/11/16 JI, added environment variables to describe where the
; programs and data are stored.
; 2012/10/01 Terje Fredvik, if run by multiple processes in Oslo get the
; hv_root directory from the OSLO_HV_ROOT environment variable instead of
; getting this info from hv_writtenby. 
;
;
; See the wiki
;
; http://www.helioviewer.org/wiki/index.php?title=JP2Gen
; 
; for more information on setting up JPGen
;
FUNCTION HV_STORAGE,write_this,nickname = nickname, no_db = no_db, no_log = no_log, no_jp2 = no_jp2
;
  wby = HV_WRITTENBY(write_this)
;
; Where the HV programs are kept
;
  hv_progs = wby.local.jp2gen
;
; Where the output from the HV progs go.
;
  ;; If run by multiple processes in Oslo the OSDCS environment variable is set
  hv_root = getenv('OSLO_HV_ROOT')
  IF hv_root EQ '' THEN hv_root = wby.local.jp2gen_write
;
; ----------- No user changes required below here ----------------
; The write subdirectory 
;
  hv_write = hv_root + 'write' + path_sep() 
  ;if not(is_dir(hv_write)) then spawn,'mkdir -p '+ hv_write
  if not(is_dir(hv_write)) then file_mkdir ,hv_write
; Outgoing
;
  outgoing = hv_write + 'outgoing' + path_sep()
  ;if not(is_dir(outgoing)) then spawn,'mkdir -p '+ outgoing
  if not(is_dir(outgoing)) then file_mkdir, outgoing

;
; Web - notices from JP2Gen that are made available via the web.
;
  web = hv_write + 'web' + path_sep()
  ;if not(is_dir(web)) then spawn,'mkdir -p '+ web
  if not(is_dir(web)) then file_mkdir,web
;
; Update the root for the version number and device nickname
;
  hvr = hv_write + 'v' + trim((HVS_GEN()).source.jp2gen_version) + path_sep()
 ; if not(is_dir(hvr)) then spawn,'mkdir -p '+ hvr
  if not(is_dir(hvr)) then file_mkdir, hvr
;
; Create the necessary subdirectory locations
;
; location of all the JP2 files
;
  hvr_jp2 = hvr + 'jp2' + path_sep()
;
;
;
  if keyword_set(nickname) then begin
;
; JP2 files for a given nickname
;
     jp2_location = hvr_jp2 + nickname + path_sep()
     if not(is_dir(jp2_location)) then begin
        if not(keyword_set(no_jp2)) then begin
           ;spawn,'mkdir -p '+ jp2_location
           file_mkdir, jp2_location
        endif
     endif
;
; Log files
;
     log_location = hvr + 'log' + path_sep() + nickname + path_sep()
     if not(is_dir(log_location)) then begin
        if not(keyword_set(no_log)) then begin
           ;spawn,'mkdir -p '+ log_location
           file_mkdir,log_location
        endif
     endif
;
; Database
;
     db_location = hvr + 'db' + path_sep() + nickname + path_sep()
     if not(is_dir(db_location)) then begin
        if not(keyword_set(no_db)) then begin
           ;spawn,'mkdir -p '+ db_location
           file_mkdir,db_location
        endif
     endif
     
     return,{hv_root:hv_root,$
             hv_write:hv_write,$
             outgoing:outgoing,$
             web:web,$
             hvr:hvr,$
             hvr_jp2:hvr_jp2,$
             jp2_location:jp2_location,$
             log_location:log_location,$
             db_location:db_location,$
             NotGiven:'NotGiven'}
  endif else begin

     return,{hv_root:hv_root,$
             hv_write:hv_write,$
             outgoing:outgoing,$
             web:web,$
             hvr:hvr,$
             hvr_jp2:hvr_jp2,$
             NotGiven:'NotGiven'}
  endelse
END
