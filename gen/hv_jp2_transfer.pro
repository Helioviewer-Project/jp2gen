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
; 2010/04/06
;
; Use with Mac OS X
;
; The functionality as implemented requires use of version 3.0.7 of
; rsync as downloaded from http://rsync.samba.org/ .  This utility was
; compiled on the local Mac OS X machine and installed into
; /usr/local/bin .  This was done since the version of rsync supplied
; on the local machine was at version 2.0.0 and so was long out of
; date.
;
; We recommend using the same procedure:  download, compile and
; install rsync from the above link and use the script below to
; transfer the JP2 files from a local OS X machine (where the FITS to
; JP2 process is running) to where your instance of the JP2 database
; is stored.
;
;
; Summary
; -------
; Program to transfer files from the outgoing directory to a remote
; location.  The program first forms a list of the subdirectories and
; files, moves those files to the remote location, and then deletes
; those files from the outgoing directory.
;
;
PRO HV_JP2_TRANSFER,details_file = details_file,ntransfer = n
  progname = 'hv_jp2_transfer'
;
; Get various details about the setup
;
  wby = HV_WRITTENBY()
  g = HVS_GEN()
  storage = HV_STORAGE()
;
;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
;
; define the transfer script
;
  transfer_details = ' -e ssh -l ' + $
                     wby.transfer.remote.user + '@' + $
                     wby.transfer.remote.machine + ':' + $
                     wby.transfer.remote.incoming + $
                     'v' + g.source.jp2gen_version + path_sep()
;
; Get a list of the JP2 files and their subdirectories in the outgoing directory
;
  sdir = storage.outgoing
  a = file_list(find_all_dir(sdir),'*.jp2')
  print,progname + ': looking in '+sdir
  if not(isarray(a)) then begin
     note = 'No files to transfer'
     print, note
     HV_LOG_WRITE,'transfer_log',note,/transfer
     n= 0
  endif else begin
     n = long(n_elements(a))
     b = a
     these_inst = [g.MinusOneString]
     for i = long(0), n-long(1) do begin
        b[i] = strmid(a[i],strlen(sdir),strlen(a[i])-strlen(sdir)) 
        if (!VERSION.OS_NAME) eq 'Mac OS X' then begin
           b[i] = strmid(b[i],1)
        endif
        split = strsplit(b[i],path_sep(),/extract)
        dummy = where(split[0] eq these_inst,already_seen)
        if (already_seen eq 0) then begin
           these_inst = [these_inst,split[0]]
        endif
     endfor
     these_inst = these_inst[1:*]
;
; Convert all the directories to the remote group
;
     grpchng = wby.transfer.local.group + ':' + $
               wby.transfer.remote.group
     for i = 0,n_elements(these_inst)-1 do begin
        spawn,'chown -R ' + grpchng + ' ' + storage.outgoing + these_inst[i]
        spawn,'chmod 775 -R ' + storage.outgoing + these_inst[i]
     endfor
;
; Connect to the remote machine and transfer files plus their structure
;
     cd,sdir,current = old_dir
;
; Open connection to the remote machine and start transferring
;
     for i = long(0), n-long(1) do begin
; change permission of the subdirectories and files
        spawn,'chmod 775 '+ b[i]
; change ownership of the file into the helioviewer group
        spawn,'chown -R ' + grpchng + ' ' + b[i]
; OS specific commands
        if (!VERSION.OS_NAME) eq 'Mac OS X' then begin
           tcmd = wby.transfer.local.tcmd_osx
        endif
        if (!VERSION.OS_NAME) eq 'linux' then begin
           tcmd = wby.transfer.local.tcmd_linux
        endif
; transfer
        spawn,tcmd + $
              ' -Ravxz --exclude "*.DS_Store" ' + $
              b[i] + ' ' + $
              transfer_details
        print,progname + ': transferred ' + sdir + b[i] + ' to ' + $
              wby.transfer.remote.machine + ':' + $
              wby.transfer.remote.incoming
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
     d = find_all_dir(sdir)     ; get all the subdirectories
;
; get the creation time and depth if each sub-directory
;
     day = 60.0*60.0*24.0       ; day in seconds
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

           if (diff ge (2.0*month)) then begin
              print, progname + ': removing '+ d[z[j]] + '(' +trim(diff) + ' seconds).'
              spawn,'rmdir ' + d[z[j]]
           endif
        endfor
     endfor

  endelse
  
  return
end
