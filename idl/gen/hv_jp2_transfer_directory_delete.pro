; Purpose    : This routine checks the creation times of the directory and sub directories 
;              containing the outgoing files.
;              This routine will also check the deletion status of each outgoing file. 
;              If the deletion status of all outgoing files is true, and that directory  was created
;              more than 2 months ago, then that directory is deleted
;
; Inputs     : FILE_DEL_RESULTS: A string array of N files containing the deletion status
;              outgoing file. In the case of deletion, it stores a string with a message like:
;              hv_jp2_transfer: deleting C:\Users\outgoing_file.jp2
;              And stores an empty string '' in the case that the file is not deleted

;              SDIR: Directory in which outgoing files are stored 
;


pro hv_jp2_transfer_directory_delete,sdir,file_del_results

  
    d = find_all_dir(sdir)  ; get all the subdirectories
    help,calls=calls
    ;
    ; get the creation time and depth if each sub-directory
    ;
    day = 60.0*60.0*24.0    ; day in seconds
    month = day*28.0
    now = systime(1)
    nsep = intarr(n_elements(d))
    mr = fltarr(n_elements(d))
    
    for i = 0,n_elements(d)-1 do begin
      nsep[i] = n_elements(str_index(d[i],path_sep()))
      stc=file_info(d[0])
      mr[i] = stc.ctime
    endfor
    ;
    ; Go through the directories, from deepest first and calculate how old
    ; they are.  Remove them if they are more than two months old.
    ;
    nsep_max = max(nsep)
    for i = nsep_max,nsep_max-1,-1 do begin
        z = where(nsep eq i)       
        for j = 0,n_elements(z)-1 do begin
          diff = now - mr[z[j]]
          ;for testing, time threshold is set to 2, not 2 months
          file_i = where(file_del_results eq '',count)
          if (diff ge (2*month)) and (count eq 0) and file_test(d[z[j]],/DIRECTORY)  then begin
            print, calls[0] + ': removing '+ d[z[j]] + '(' +trim(diff) + ' seconds).'
            FILE_DELETE,d[z[j]]
            print,'file_delete: ' + d[z[j]]
          endif
        endfor        
    endfor

end