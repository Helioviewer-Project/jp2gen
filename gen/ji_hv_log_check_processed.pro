;
; 16 September 2009
;
; Get all the log file information
;
FUNCTION JI_HV_LOG_CHECK_PROCESSED,nickname
;
; Get some details on how the log file name is constructed.  Pass in a
; dummy time, in this case, UTC
;
  get_utc,utc
  c = JI_HV_LOG_FILENAME_CONVENTION(nickname,utc2str(utc),utc2str(utc),/components)
;
; Get the log file directories
;
  log = (JI_HV_STORAGE(nickname = nickname)).log_location
  dirs1 = expand_dirs(log)
  dirs2 = find_all_dir('+' + log)
  if n_elements(dirs1) gt n_elements(dirs2) then dirs = dirs1 else dirs = dirs2
;
; Get the subdirectories
;
  nd = n_elements(dirs)
  len0 = strlen(dirs[0])
  index = strarr(nd-1)
  nmax = -1
  for i = 1,nd-1 do begin
     index[i-1] = strmid(dirs[i],len0+1,strlen(dirs[i])) ; remove the root filename to get the date sub-directories
     dummy = file_list(dirs[i],files = files)
     nmax = max([nmax,n_elements(files)])
  endfor
;
; Get the start and end dates of all the log files
;
  logged = strarr(nd-1,nmax,2)
  logged[*,*,*] = '-1'
  logtime = fltarr(nd-1,nmax,2)
  for i = 1,nd-1 do begin
     dummy = file_list(dirs[i],files = files)
     if files[0] eq '' then begin
        files[0] = '-1'
     endif else begin
        for j = 0,n_elements(files)-1 do begin
           split = strsplit(files[j],c.separator,/regex,/extract)
           logged[i-1,j,0] = split[1]
           logged[i-1,j,1] = strmid(split[2],0,strlen(split[2])-4)
           logtime[i-1,j,0] = anytim2tai(logged[i-1,j,0])
           logtime[i-1,j,1] = anytim2tai(logged[i-1,j,1])
        endfor
     endelse
  endfor
;
; Get the most recent time
;
  mri = where(logtime eq max(logtime), count)
  if count gt 1 then mr = logged[mri[0]] else mr = logged[mri]
;
  return,{nickname:nickname,index:index,logged:logged,most_recent:mr}
end
