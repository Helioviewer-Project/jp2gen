;
; 1 October 2010
;
; Goes to the NRL website and downloads the latest backgrounds
;
;

;
;
;
FUNCTION HV_SPLIT_STRING,a,pattern,last = last
  z = STRSPLIT(a, pattern, count = count, /extract)
  remote_list[j] = z[count-1]
  if keyword_set(last) then begin
     answer = z[count-1]
  endif else begin
     answer = z
  endelse
  return,answer
end


PRO HV_LASCO_UPDATE_ALTERNATE_BACKGROUNDS,details_file = details_file
;
;
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_lasco_c2'
  info = CALL_FUNCTION(details_file)
;
; Server, path and type
;
  server = strarr(2)
  path = strarr(2)
  type = strarr(2)
;
; Rolled
;
  server[0] = 'http://lasco-www.nrl.navy.mil'
  path[0] = '/content/retrieve/monthly/rolled'
  type[0] = 'rolled'
;
; Regular
;
  server[1] = 'http://lasco-www.nrl.navy.mil'
  path[1] = '/content/retrieve/monthly'
  type[1] = 'regular'
;
; Query the remote server and download
;
  for i = 0,n_elements(server)-1 do begin
;
; Get the remote files
;
     remote_http = sock_find(server,'*.fts',path = path)
     n = n_elements(remote_http)
     remote_list = strarr(n)
     for j = 0,n-1 do begin
        remote_list[j] = HV_SPLIT_STRING(remote_http[i],'/',/last)
     endfor
;
; Check the local files
;
     if type[i] eq 'rolled' then begin
        subdir = 'rolled/'
     endif else begin
        subdir = ''
     endelse
     local = info.alternate_backgrounds + subdir
     local_pathlist = file_list(local)
     m = n_elements(local_pathlist)
     local_list = strarr(m)
     for j = 0,m-1 do begin
        local_list[j] = HV_SPLIT_STRING(local_pathlist[i],'/',/last)
     endfor
;
; Find which files we need to download
;
     for j = 0,n-1 do begin
        test = where(remote_list[j] eq local_list,count)
        if count eq 0 then begin
           outdir = outdir
           sock_copy,remote_http[j],outdir = outdir
           print,progname + ': ' + remote_http[j] + ' copied to ' + outdir
        endif
     endfor
  endfor
return
end
