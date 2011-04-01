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
PRO HV_JP2_TRANSFER,ntransfer = n,$ ; number of files transferred
                    web = web, $ ; wrote the details of the transfer toa text file that can be picked up by HV_JP2GEN_MONITOR
                    delete_transferred = delete_transferred,$ ; delete the transferred files from the outgoing directory
                    force_delete = force_delete,$ ; force the delete of the JP2 file
                    sdir = sdir ; directory where the JP2 files are stored
  progname = 'hv_jp2_transfer'
;
; Get various details about the setup
;
  wby = HV_WRITTENBY()
  g = HVS_GEN()
  storage = HV_STORAGE()
  storage2 = HV_STORAGE(nickname = 'HV_TRANSFER_LOGS',/no_db,/no_jp2)
;
; Transfer start-time
;
  transfer_start_time = JI_SYSTIME()
;
;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
;
; define the transfer script
;
  transfer_details = ' -e ssh -l ' + $
                     wby.transfer.remote.user + '@' + $
                     wby.transfer.remote.machine + ':' + $
                     wby.transfer.remote.incoming + $
                     'v' + g.source.jp2gen_version + path_sep() + $
                     'jp2/'
;
; Get a list of the JP2 files and their subdirectories in the outgoing directory
;
  if not(keyword_set(sdir)) then begin
     sdir = storage.outgoing
  endif
  sdir = EXPAND_TILDE(sdir)
  print,progname + ': looking in '+sdir
  print,progname + ': transfer to '+ wby.transfer.remote.machine + ':' + $
                     wby.transfer.remote.incoming 
  a = file_list(find_all_dir(sdir),'*.jp2')
  if (not(isarray(a)) or (a[0] eq 'aaa.jp2')) then begin
     transfer_results = ['No files to transfer']
     print, transfer_results
     n= 0
  endif else begin
;
; Get the full path
;
     sdir_full = HV_PARSE_LOCATION(a[0],/location)
;
; Part of the command to change groups
;
     grpchng = wby.transfer.local.group + ':' + $
               wby.transfer.remote.group
;
; Open a transfer details array
;
     transfer_results = [g.MinusOneString]
     n = long(n_elements(a))
     b = a
;     these_inst = [g.MinusOneString]
;
; Go through the entire list and find all the unique subdirectories
;
     uniq = [g.MinusOneString]
     for i = long(0), n-long(1) do begin
        b[i] = HV_PARSE_LOCATION(a[i],/transfer_path)
;        if (!VERSION.OS_NAME) eq 'Mac OS X' then begin
;           b[i] = strmid(b[i],1)
;        endif
        c = HV_PARSE_LOCATION(a[i],/transfer_path,/all_subdir)
        for j = 0,n_elements(c)-2 do begin
           dummy = where(c[j] eq uniq,count)
           if (count eq 0) then begin
              uniq = [uniq,c[j]]
              print,progname + ': will change permission on directory '+ c[j]
           endif
        endfor
     endfor
     uniq = uniq[1:*]
;
; Change the group ownerships and accessibility for all the unique subdirectories
;
     nu = n_elements(uniq)
     for i = long(0), nu-long(1) do begin
;        spawn,'chown ' + grpchng + ' ' + sdir_full + uniq[i]
;        spawn,'chmod 775 ' + sdir_full + uniq[i]
     endfor
;
; Connect to the remote machine and transfer files plus their structure
;
     cd,sdir_full,current = old_dir
;
; Open connection to the remote machine and start transferring
;
     filetotal = trim(n)
     for i = long(0), n-long(1) do begin
;
        filenumber = trim(i+1)
; change permission of the subdirectories and files
;        spawn,'chmod 775 '+ b[i]
; change ownership of the file into the helioviewer group
;        spawn,'chown ' + grpchng + ' ' + b[i]

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
              transfer_details, result,error, exit_status = exit_status
        transfer_results = [transfer_results,' ','-- start --',filenumber + ' out of ' + filetotal,b[i],systime(0),result,error,'exit_status='+trim(exit_status)]
;
; Remove files ONLY if there has been an error-free transfer
;
        if exit_status eq 0 then begin
           if (keyword_set(delete_transferred) and (sdir eq expand_tilde(storage.outgoing))) then begin ; ensure that the user has made a request to delete from the outgoing directory; this directory is the only one from which files may be deleted.  Intended to make the deletion process harder to activate and so keeps the JP2 files safe.
              if keyword_set(force_delete) then begin ; if you don't force the delete, you will be asked about deleting every file.  This is for extra safety in deleting JP2 files.
                 modifier = ' -f '
              endif else begin
                 modifier = ' -i '
              endelse
              spawn,'rm' + modifier + b[i] ; delete the originals - three layers of protection included.
              print,' '
              print,filenumber + ' out of ' + filetotal
              print,progname + ': no error reported on transfer of ' + sdir_full + b[i] + ' to ' + $
                    wby.transfer.remote.machine + ':' + $
                    wby.transfer.remote.incoming
              print,progname +': deleting '+b[i]
              transfer_results = [transfer_results,progname +': deleting ' + sdir_full + b[i]]
           endif else begin
              print,' '
              print,filenumber + ' out of ' + filetotal
              print,progname + ': no error reported on transfer of ' + sdir_full + b[i] + ' to ' + $
                    wby.transfer.remote.machine + ':' + $
                    wby.transfer.remote.incoming
              print,progname +': keeping '+b[i]
              transfer_results = [transfer_results,progname +': keeping ' + sdir_full + b[i]]
           endelse
        endif else begin
           print,' '
           print,filenumber + ' out of ' + filetotal
           print,progname +': error in transfer of ' + sdir_full + b[i] + ' to ' + $
                 wby.transfer.remote.machine + ':' + $
                 wby.transfer.remote.incoming
           print,progname +': check logs.'
        endelse
     endfor
     cd,old_dir
;
; Cleanup old directories that have been untouched for a long time
;
     if keyword_set(delete_transferred) then begin
        d = find_all_dir(sdir)  ; get all the subdirectories
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
     endif
  endelse
;
; Write a logfile describing what was transferred
;
  HV_LOG_WRITE,'transfer_log',transfer_results,transfer = transfer_start_time + '_'
;
; Write a file for the web, if required
;
  IF keyword_set(web) then begin
     HV_WEB_TXTNOTE,progname,transfer_results,/details
  ENDIF
  return
end
