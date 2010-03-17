;
; Copy a set of given list of files to the outgoing directory
;
;
PRO HV_COPY2OUTGOING,files,search = search
  progname = 'hv_copy2outgoing'
;
; get the outgoing directory for this nickname
;
  storage = HV_STORAGE(nickname = 'dummy')
  outgoing_root = storage.outgoing
;
; If the input array is a single string, then go to the directory
; which is defined by that string and move the files
;
  if not(keyword_set(search)) then begin
     search = '*.jp2'
  endif
  if not(isarray(files)) then begin
     print,progname + ': passed a directory.  Looking for files in ' + files + ' containing ' + search
     files = file_list(find_all_dir(files),search)
  endif
;
; Split the path of the file.
;
  n = long(n_elements(files))
  if (files(0) eq '-1' and n eq 1) then begin
     print,progname + ': No files to be moved.'
  endif else begin
     
     for i = long(1),n- long(1) do begin 
        if files[i] ne 'already_written' then begin
           z = STRSPLIT(files[i],path_sep(),/extract)
           nz = n_elements(z)
           s = z[nz-6] + path_sep() + $
               z[nz-5] + path_sep() + $
               z[nz-4] + path_sep() + $
               z[nz-3] + path_sep() + $
               z[nz-2] + path_sep() + $
               z[nz-1]
;
; Move the JP2 file to the outgoing directory
;
           cd,storage.hvr_jp2,current = old_dir
           spawn,'cp --parents ' + s + ' ' + outgoing_root
           cd,old_dir
           print,progname + ': transferred ' + files[i] + ' to ' + outgoing_root
        endif
     endfor

  endelse
  return
end
