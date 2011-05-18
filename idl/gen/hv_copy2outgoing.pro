;
; Copy a set of given list of files to the outgoing directory
;
;
PRO HV_COPY2OUTGOING,files,search = search,delete_original = delete_original
  progname = 'hv_copy2outgoing'
;
  g = HVS_GEN()
;
; get the outgoing directory for this nickname
;
  storage = HV_STORAGE(nickname = 'dummy')
  outgoing_root = storage.outgoing
;
; Operating system
;
  os_name = (!VERSION).os_name
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
  endif else begin
     dummy = where(files eq g.already_written,naw)
     dummy = where(files eq g.MinusOneString,nm1)
     dummy = where(files eq '',nnull)
     if ( (naw + nm1 + nnull) eq n_elements(files) ) then begin
        print,progname + ': No proper file names passed.'
        files = strarr(1)
        files[0] = g.MinusOneString
     endif else begin
        nawind = where(files ne g.already_written,naw) ; remove entries from the list that may have already been written
        if naw gt 0 then begin
           files = files(nawind)
        endif
        nm1ind = where(files ne g.MinusOneString,nm1) ; remove entries from the list that indicate failed processing
        if nm1 gt 0 then begin
           files = files(nm1ind)
        endif
        nnullind = where(files ne '',nnull) ; empty files names
        if nnull gt 0 then begin
           files = files(nnullind)
        endif
     endelse
  endelse
;
; Split the path of the file.
;
  n = long(n_elements(files))
  if (files[0] eq '-1' and n eq 1) then begin
     print,progname + ': No files to be moved.'
  endif else begin
     if files[0] eq '-1' then offset = long(1) else offset = long(0)
     for i = offset,n- long(1) do begin 
        if files[i] ne 'already_written' then begin
           z = STRSPLIT(files[i],path_sep(),/extract)
           nz = n_elements(z)
           s = z[nz-6] + path_sep() + $ ; nickname
               z[nz-5] + path_sep() + $ ; measurement
               z[nz-4] + path_sep() + $ ; year
               z[nz-3] + path_sep() + $ ; month
               z[nz-2] + path_sep() + $ ; day
               z[nz-1]                  ; filename
;
; Move the JP2 file to the outgoing directory
;
           cd,storage.hvr_jp2,current = old_dir
           if os_name eq 'Mac OS X' then begin
              cpcmd = 'cp -R '
              outd = outgoing_root
              for j = 6, 2, -1 do begin
                 outd = outd + z[nz-j] 
                 print,outd
                 if not(is_dir(outd)) then begin
                    spawn,'mkdir ' + outd
                 endif
                 outd = outd + path_sep()
              endfor

           endif else begin
              cpcmd = 'cp --parents '
              outd = outgoing_root
           endelse
           spawn,cpcmd + s + ' ' + outd
           print,progname + ': transferred ' + files[i] + ' to ' + outgoing_root
           if keyword_set(delete_original) then begin
              spawn,'rm ' + s
              print,progname + ': deleted original file ' + files[i]
           endif
           cd,old_dir

        endif
     endfor

  endelse
  return
end
