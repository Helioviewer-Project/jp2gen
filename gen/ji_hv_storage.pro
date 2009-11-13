;
; 7 April 09
;
; Edit this file to point the code to where the output files should be
; written
; 
;
FUNCTION JI_HV_STORAGE,nickname = nickname
;
; The root location where the programs and the jp2 files are stored
;  default = '~hv/'.  Change as appropriate.
;
  hv_root = getenv("HV_JP2GEN") + '/'
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
     
     err_location = hvr + 'err/'
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
     return,{hv_root:hv_root,$
             NotGiven:'NotGiven'}
  endif else begin
     dummy = where(nickname eq nicknames, wc)
     if wc eq 1 then begin
        hvr = hv_root + nickname + '/'
        return,{hv_root:hvr,$
                jp2_location:hvr + 'jp2/',$
                err_location:hvr + 'err/',$
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
