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
;
; 
;
FUNCTION JI_HV_STORAGE,nickname = nickname
;
;
; Where the HV programs are kept
;
  hv_progs = getenv("HV_JP2GEN") + '/'
;
; Where the output from the HV progs go.
;
  hv_root = getenv("HV_JP2GEN_WRITE") + '/'
;
; ----------- No user changes required below here ----------------
; The subdirectory of <hv_root> where the JP2 are stored
;
  hv_root = hv_root + 'write/v' + trim((JI_HV_WRITTENBY()).source.jp2gen_version)+ '/'
  if not(is_dir(hv_root)) then spawn,'mkdir -p '+ hv_root
  nicknames = (JI_HV_OIDM2('EIT')).nicknames
  for i = 0, n_elements(nicknames)-1 do begin
     hvr = hv_root + nicknames(i) + '/'
     spawn,'mkdir -p '+ hvr
;
; Create the necessary subdirectory locations
;
     jp2_location = hvr + 'jp2/'
     if not(is_dir(jp2_location)) then begin
        spawn,'mkdir '+ jp2_location
     endif
     
     err_location = hvr + 'log/'
     if not(is_dir(err_location)) then begin
        spawn,'mkdir '+ err_location
     endif
     
     log_location = hvr + 'log/'
     if not(is_dir(log_location)) then begin
        spawn,'mkdir '+ log_location
     endif
  endfor

;
; Return the structure
;
  if not(keyword_set(nickname)) then begin
     return,{hv_progs:hv_progs,$
             hv_root:hv_root,$
             NotGiven:'NotGiven'}
  endif else begin
     dummy = where(nickname eq nicknames, wc)
     if wc eq 1 then begin
        hvr = hv_root + nickname + '/'
        return,{hv_progs:hv_progs,$
                hv_root:hvr,$
                jp2_location:hvr + 'jp2/',$
                err_location:hvr + 'log/',$
                log_location:hvr + 'log/',$
                NotGiven:'NotGiven'}
     endif
     if wc eq 0 then begin
        print,'The passed nickname "' + nickname + '" is not a recognized nickname.'
        print,'Please check the nickname and the file JI_HV_OIDM2.PRO'
        print,'Stopping.'
        stop
     endif
     if wc ge 2 then begin
        print,'The passed nickname "' + nickname + '" resulted in multiple entries in the nickname list.'
        print,'This should not occur.  Please check the nickname and the file JI_HV_OIDM2.PRO'
        print,'Stopping.'
        stop
     endif
  endelse
END
