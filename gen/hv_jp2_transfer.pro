;
; Program to transfer files from the outgoing directory to a remote
; location.  The program first forms a list of the subdirectories and
; files, moves those files to the remote location, and then deletes
; those files from the outgoing directory.
;
;
PRO HV_JP2_TRANSFER,nickname,transfer_details = transfer_details
  progname = 'hv_jp2_transfer'
;
  if NOT(KEYWORD_SET(transfer_details)) THEN BEGIN
;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
     transfer_details = ' -e ssh -l ireland@helioviewer.nascom.nasa.gov:/home/ireland/incoming_auto/v0.8/'
  endif 
;
  storage = HV_STORAGE(nickname = nickname)
;
; Get a list of the JP2 files and their subdirectories in the outgoing directory
;
  sdir = storage.outgoing
  a = file_list(find_all_dir(sdir),'*.jp2')

  if not(isarray(a)) then begin
     note = 'No files to transfer'
     print, note
     HV_LOG_WRITE,'transfer_log',note,/transfer
  endif else begin
     n = long(n_elements(a))
     b = a
     for i = long(0), n-long(1) do begin
        b[i] = strmid(a[i],strlen(sdir),strlen(a[i])-strlen(sdir)) 
     endfor
;
; Connect to the remote machine and transfer files plus their structure
;
     cd,sdir,current = old_dir
;
; Open connection to the remote machine and start transferring
;
     for i = long(0), n-long(1) do begin
        spawn,'rsync -Ravxz --exclude "*.DS_Store" ' + $
              b[i] + ' ' + $
              transfer_details
     endfor
;
; Write a logfile describing what was transferred
;
     HV_LOG_WRITE,'transfer_log',b,/transfer
;
; Remove files from the outgoing that have been transferred
;
     for i = long(0), n-long(1) do begin
        spawn,'rm -f ' + b[i]
     endfor
     cd,old_dir
;
; Cleanup old directories that have been untouched for a long time
;
     d = find_all_dir(sdir)
;
; Reorder the returned directories to get the deepest ones first
;
     nsep = intarr(n_elements(d))
     for i = 0,n_elements(d)-1 do begin
        nsep[i] = n_elements(str_index(d[i],path_sep()))
     endfor
     nsep_max = max(nsep)
     for i = nsep_max,nsep_max-4,-1 do begin
        z = where(nsep eq i)
        for j = 0,n_elements(z)-1 do begin
           finfo = file_info(d[z[i]])

        endfor
     endfor
  endelse

  return
end
