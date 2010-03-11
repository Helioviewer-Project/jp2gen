;
; Move a set of given list of files to the outgoing directory
;
;
PRO HV_JP2_MOVE2OUTGOING,files
  progname = 'hv_jp2_move2outgoing'
;
; get the outgoing directory for this nickname
;
  storage = HV_STORAGE(nickname = 'dummy')
  outgoing_root = storage.outgoing
;
; Split the path of the file.
;
  n = n_elements(files)
  if (files(0) eq '-1' and n eq 1) then begin
     print,progname + ': No files to be moved.'
  endif else begin
     
     for i = 1,n-1 do begin
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
     endfor

  endelse


  return
end
