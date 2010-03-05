;
; Move a set of given list of files to the outgoing directory
;
;
PRO HV_JP2_MOVE2OUTGOING,nickname,files
  progname = 'hv_jp2_move2outgoing'
;
; get the outgoing directory for this nickname
;
  outgoing_root = (HV_STORAGE(nickname = nickname)).outgoing
;
; Split the path of the file.
;
  if (files(0) eq '-1' and n_elements(files) eq 1) then begin
     print,progname + ': No files to be moved.'
  endif else begin
     for i = 0,n-1 do begin
        z = STRSPLIT(files[i],path_sep(),/extract)
        nz = n_elements(z)
;
; Construct the path for the new outgoing directory and create it
;
        outgoing = outgoing_root + 
;
; Move the JP2 file to the outgoing directory
;
        spawn,'cp ' + files[i] + ' ' + outgoing + path_sep() + '.'

     endfor

  endelse


  return
end
