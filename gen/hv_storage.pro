;
; 2009/04/07 JI, original
; 2009/11/16 JI, added environment variables to describe where the
; programs and data are stored.
;
;
; See the wiki
;
; http://www.helioviewer.org/wiki/index.php?title=JP2Gen
; 
; for more information on setting up JPGen
;
FUNCTION HV_STORAGE,nickname = nickname
;
;
; Where the HV programs are kept
;
  hv_progs = getenv("HV_JP2GEN") + path_sep()
;
; Where the output from the HV progs go.
;
  hv_root = getenv("HV_JP2GEN_WRITE") + path_sep()
;
; ----------- No user changes required below here ----------------
; The write subdirectory 
;
  hv_write = hv_root + 'write' + path_sep() 
  if not(is_dir(hv_write)) then spawn,'mkdir -p '+ hv_write
;
; Outgoing
;
  outgoing = hv_write + 'outgoing' + path_sep()
  if not(is_dir(outgoing)) then spawn,'mkdir -p '+ outgoing
;
; Update the root for the version number and device nickname
;
  hvr = hv_write + 'v' + trim((HV_WRITTENBY()).source.jp2gen_version) + path_sep()
  if not(is_dir(hvr)) then spawn,'mkdir -p '+ hvr
;
; Create the necessary subdirectory locations
;
; location of all the JP2 files
;
  hvr_jp2 = hvr + 'jp2' + path_sep()
;
; JP2 files for a given nickname
;
  jp2_location = hvr_jp2 + nickname + path_sep()
  if not(is_dir(jp2_location)) then begin
     spawn,'mkdir -p '+ jp2_location
  endif
;
; Log files
;
  log_location = hvr + 'log' + path_sep() + nickname + path_sep()
  if not(is_dir(log_location)) then begin
     spawn,'mkdir -p '+ log_location
  endif
;
; Database
;
  db_location = hvr + 'db' + path_sep() + nickname + path_sep()
  if not(is_dir(db_location)) then begin
     spawn,'mkdir -p '+ db_location
  endif

  return,{hv_root:hv_root,$
          hv_write:hv_write,$
          outgoing:outgoing,$
          hvr:hvr,$
          hvr_jp2:hvr_jp2,$
          jp2_location:jp2_location,$
          log_location:log_location,$
          db_location:db_location,$
          NotGiven:'NotGiven'}
END
