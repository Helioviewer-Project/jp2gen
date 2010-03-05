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
; The subdirectory of <hv_root> where the JP2 are stored
;
  hv_root = hv_root + 'write' + path_sep() + 'v' + trim((HV_WRITTENBY()).source.jp2gen_version) + path_sep()
  if not(is_dir(hv_root)) then spawn,'mkdir -p '+ hv_root
;
; Create the necessary subdirectory locations
;
; JP2 files
;
  jp2_location = hv_root + 'jp2' + path_sep() + nickname + path_sep()
  if not(is_dir(jp2_location)) then begin
     spawn,'mkdir -p '+ jp2_location
  endif
;
; Log files
;
  log_location = hv_root + 'log' + path_sep() + nickname + path_sep()
  if not(is_dir(log_location)) then begin
     spawn,'mkdir -p '+ log_location
  endif
;
; Database
;
  db_location = hv_root + 'db' + path_sep() + nickname + path_sep()
  if not(is_dir(db_location)) then begin
     spawn,'mkdir -p '+ db_location
  endif
;
; Outgoing
;
  outgoing = hv_root + 'outgoing' + path_sep()

  return,{jp2_location:jp2_location,$
          log_location:log_location,$
          db_location:db_location,$
          outgoing:outgoing,$
          NotGiven:'NotGiven'}
END
