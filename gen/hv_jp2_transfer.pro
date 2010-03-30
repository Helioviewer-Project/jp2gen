;
; Details on how to transfer data from the production machine to the
; server
;
; As of 2010/03/24 the commands used are
;
; chown -R <local.group>:<remote.group> <filename>
; rsync -Ravxz --exclude "*.DS_Store" <filename> -e ssh -l
; <remote.user> @ <remote.machine> : <remote.incoming>
;
; Note that
;
; (1) local and remote computers MUST have the same group with the
; SAME group IDs and group names
; (2) the owner of the JP2 files MUST be member of that group on both
; the LOCAL machine and the REMOTE machine
;
; Linux gotcha: Ubuntu 9.10 (2010/03/24) requires that the JP2
; creation machine be RESTARTED before the group assignment for a user
; is recognized by the system.  For example, if you attempt to put
; a user into a group, then the change only "sticks" after a restart.
; This is important for the current application as you want the
; username on both the local and remote machines to be in the same groups.
;
;
;
; Program to transfer files from the outgoing directory to a remote
; location.  The program first forms a list of the subdirectories and
; files, moves those files to the remote location, and then deletes
; those files from the outgoing directory.
;
;
PRO HV_JP2_TRANSFER,details_file = details_file,ntransfer = n
  progname = 'hv_jp2_transfer'
;
  if NOT(KEYWORD_SET(details_file)) THEN details_file = 'hvs_gen'
; 
  info = CALL_FUNCTION(details_file)
  if NOT(KEYWORD_SET(transfer_details)) THEN BEGIN
;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
     transfer_details = ' -e ssh -l ireland@helioviewer.nascom.nasa.gov:/home/ireland/incoming2/v0.8/'
  endif 
;
  storage = HV_STORAGE()
;
; Get a list of the JP2 files and their subdirectories in the outgoing directory
;
  sdir = storage.outgoing
  a = file_list(find_all_dir(sdir),'*.jp2')

  if not(isarray(a)) then begin
     note = 'No files to transfer'
     print, note
     HV_LOG_WRITE,'transfer_log',note,/transfer
     n= 0
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
;        file_chmod,b[i],/g_execute,/g_read,/g_write
        spawn,'chown -R ireland:helioviewer ' + b[i]
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

  endelse
;
; Cleanup old directories that have been untouched for a long time
;
  d = find_all_dir(sdir) ; get all the subdirectories
;
; get the creation time and depth if each sub-directory
;
  day = 60.0*60.0*24.0 ; day in seconds
  month = day*28.0
  now = systime(1)
  nsep = intarr(n_elements(d))
  mr = fltarr(n_elements(d))
  for i = 0,n_elements(d)-1 do begin
     nsep[i] = n_elements(str_index(d[i],path_sep()))
     mr[i] = (file_info(d[i])).mtime
  endfor
;
; Go through the directories, from deepest first and calculate how old
; they are.  Remove them if they are more than two months old.
;
  nsep_max = max(nsep)
  for i = nsep_max,nsep_max-2,-1 do begin
     z = where(nsep eq i)
     for j = 0,n_elements(z)-1 do begin
        diff = now - mr[z[j]]
        print, trim(i) + ' '+ d[z[j]] + ' ' +trim(diff) + ' seconds.'
        if (diff ge (2.0*month)) then begin
           spawn,'rmdir ' + d[z[j]]
        endif
     endfor
  endfor
  stop
  return
end
