;
; 4 Nov
;
PRO JI_HV_LOG_CREATE_SUBDIRECTORY,log_location,nickname,date = date,subdir = subdir
  if not(is_dir(log_location + nickname)) then begin
     subdir = log_location + nickname
     spawn,'mkdir ' + subdir
     if keyword_set(date) then begin
        subdir = log_location + nickname + '/' + date
        spawn,'mkdir ' + subdir
        subdir = subdir + '/'
     endif
  endif else begin
     if keyword_set(date) then begin
        subdir = log_location + nickname + '/' + date
        spawn,'mkdir ' + subdir
        subdir = subdir + '/'
     endif
  endelse
return
end
