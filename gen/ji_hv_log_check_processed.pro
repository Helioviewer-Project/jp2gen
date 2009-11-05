;
; 16 September 2009
;
; Simple function to return the dates of the last processed data.
; Note that this function works by simply checking the date of the
; most recent directory that contains a file relevant to the
; instrument "nickname".  Future versions will probably have to read
; this file to find the most recent individual FITS file that was kept.
;
;
FUNCTION JI_HV_LOG_CHECK_PROCESSED,log,nickname

   dirs1 = expand_dirs(log + nickname) ; get the log file subdirectories
   dirs2 = find_all_dir('+' + log + nickname) ; get the log file subdirectories
   if n_elements(dirs1) gt n_elements(dirs2) then dirs = dirs1 else dirs = dirs2

   last = dirs[n_elements(dirs)-1]
   

   nd = n_elements(dirs)
   index = strarr(nd-1)
   len0 = strlen(dirs[0])

   nmax = -1
   for i = 1,nd-1 do begin
      index[i-1] = strmid(dirs[i],len0+1,strlen(dirs[i])) ; remove the root filename to get the date sub-directories
      dummy = file_list(dirs[i],files = files)
      nmax = max([nmax,n_elements(files)])
   endfor

   logged = strarr(nd-1,nmax,2)
   logged[*,*] = '-1'
   for i = 1,nd-1 do begin
      dummy = file_list(dirs[i],files = files)
      if files[0] eq '' then files[0] = '-1'
      logged[i-1,0:n_elements(files)-1] = files[*]
   endfor

   return,{nickname:nickname,index:index,logged:logged}
end
