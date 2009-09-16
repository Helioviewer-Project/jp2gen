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
FUNCTION JI_HV_CHECK_PROCESSED_LOGS,log,nickname

   dirs = expand_dirs(log) ; get the log file subdirectories
   nd = n_elements(dirs)
   sdirs = strarr(nd)
   len0 = strlen(dirs[0])
   keep_infil = '' ; keep the most recent log file and its index
   keep_index = 0
   for i = 0,nd-1 do begin
      sdirs[i] = strmid(dirs[i],len0,strlen(dirs[i])-1) ; remove the root filename to get the date sub-directories
      z = strsplit(sdirs[i],'/',count = count)
      if (count eq 3) then begin
         infil = file_list(dirs[i],nickname + '*')
         if infil ne '' then begin
            keep_infil = infil
            keep_index = i
         endif
      endif
   endfor
   z = strsplit(sdirs[keep_index],'/',/extract)
   date_most_recent = z[0] + '/' + z[1] + '/' + z[2] ; calculate the date of the most recently processed data

   return,{date_most_recent:date_most_recent}
end
