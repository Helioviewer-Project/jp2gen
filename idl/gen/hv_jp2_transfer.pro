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
PRO HV_JP2_TRANSFER,write_this,$ ; a permitted project - see HV_WRITTENBY for a LIST of permitted projects
                    ntransfer = n,$ ; number of files transferred
                    web = web,$ ; wrote the details of the transfer toa text file that can be picked up by HV_JP2GEN_MONITOR
                    delete_transferred = delete_transferred,$ ; delete the transferred files from the outgoing directory
                    force_delete = force_delete,$ ; force the delete of the JP2 file
                    sdir = sdir ; directory where the JP2 files are stored
    progname = 'hv_jp2_transfer'
  
  ;if is_windows() then return
;
; Get various details about the setup
;
    wby = HV_WRITTENBY(write_this)
    g = HVS_GEN()
    storage = HV_STORAGE(write_this)
;
; Transfer start-time
;
    transfer_start_time = JI_SYSTIME()
;
;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
;
; define the transfer script
;
    nrm = n_elements(wby.transfer.remote.machine)
    transfer_details=strarr(nrm)
    if not(keyword_set(sdir)) then begin
      sdir = storage.outgoing
    endif
    sdir = EXPAND_TILDE(sdir)
    
    print,progname + ': looking in '+sdir
    a = file_list(find_all_dir(sdir),'*.jp2')
    n = long(n_elements(a))
    exit_status=intarr(nrm,n)
    transfer_results = strarr(nrm+1,n)

;ix is used as indexing to designate which remote machine for transfer destination
    for ix=0,nrm - 1 do begin
  
        remote_user = wby.transfer.remote.user(ix) 
        remote_mach = wby.transfer.remote.machine(ix) 
        remote_inc = wby.transfer.remote.incoming(ix) 
        remote_grp = wby.transfer.remote.group(ix) 
  
        transfer_details[ix] = ' -e ssh -l  ' + $
                                remote_user + '@' + $
                                remote_mach + ':' + $
                                remote_inc + $
                                'v' + g.source.jp2gen_version + path_sep() + $
                                'jp2' + path_sep()

        
            ;                   transfer_details[i] = ' -e ssh -l  ' + $
            ;                     wby.transfer.remote.user + '@' + $
            ;                     wby.transfer.remote.machine + ':' + $
            ;                     wby.transfer.remote.incoming + $
            ;                     'v' + g.source.jp2gen_version + path_sep() + $
            ;                     'jp2/'                        
            ;
            ; Get a list of the JP2 files and their subdirectories in the outgoing directory
            ;

        print,progname + ': transfer to '+ remote_mach + ':' + remote_inc

;  if (not(isarray(a)) or (a[0] eq 'aaa.jp2')) then begin
;     transfer_results = ['No files to transfer']
;     print, transfer_results
;     n= 0
;  endif else begin
;
; Get the full path
;
       sdir_full = HV_PARSE_LOCATION(a[0],/location)
       if is_windows() eq 1 then sdir_full=sdir_full.remove(0,0)
;
; Part of the command to change groups
;
       grpchng = wby.transfer.local.group + ':' + remote_grp
              
;
; Open a transfer details array
;
     ;transfer_results = [g.MinusOneString]
     
       b = a
;     these_inst = [g.MinusOneString]
;
; Go through the entire list and find all the unique subdirectories
;
       uniq = [g.MinusOneString]
       for i = long(0), n-long(1) do begin
           b[i] = HV_PARSE_LOCATION(a[i],/transfer_path)
;          if (!VERSION.OS_NAME) eq 'Mac OS X' then begin
;             b[i] = strmid(b[i],1)
;          endif
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
            print,'chown ' + grpchng + ' ' + sdir_full + uniq[i]
            print, 'chmod 775 ' + sdir_full + uniq[i]
;           spawn,'chown ' + grpchng + ' ' + sdir_full + uniq[i]
;           spawn,'chmod 775 ' + sdir_full + uniq[i]
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
        endif else begin
           tcmd = 'windows_transfer_cmd'
        endelse
        
; transfer

;        file_move,tcmd,b[i],/verbose
;        spawn,tcmd + $
;              ' -Ravxz --exclude "*.DS_Store" ' + $
;              b[i] + ' ' + $
;              transfer_details, result,error, exit_status = exit_status
        result=' 1 '
        error=' 0 '
        exit_status[ix,i]= 0
        tr = ['-- start --' , filenumber , ' out of ' , filetotal , b[i] , systime(0) , result , error , ' exit_status= ' , trim(exit_status[ix,i])]
        transfer_results[ix,i] = tr.join()
        print, tcmd + $
              ' -Ravxz --exclude "*.DS_Store" ' + $
              b[i] + ' ' + $
              transfer_details[ix]

        fn_outof_ft = filenumber + ' out of ' + filetotal + ' '
        no_err_print = progname + ': no error reported on transfer of ' + sdir_full + b[i] + ' to ' + $
        remote_mach + ':' + remote_inc
          
       endfor
    endfor

;hard coding exit_status for testing
    exit_status=[[1,0],[1,1],[0,0],[0,0],[0,0]]
    files = sdir_full + b


;
; Remove files ONLY if there has been an error-free transfer
;

     
     if (keyword_set(delete_transferred) and (sdir eq expand_tilde(storage.outgoing)))then begin
         hv_jp2_tr_file_del,exit_status,files,transfer_results=transfer_results
     endif
     
;
; Cleanup old directories that have been untouched for a long time
; In order to delete, files must be over 2 months old AND all files must have transferred correctly
     cd,old_dir
     file_del_results = transfer_results[nrm,*]
     
     if keyword_set(delete_transferred) then begin
         hv_jp2_tr_dir_del, sdir,file_del_results
     endif
     
;  endelse corresponds to line 116
;
; Write a logfile describing what was transferred
;
     HV_LOG_WRITE,'transfer_log',transfer_results,transfer = transfer_start_time + '_', write_this=write_this

; Write a file for the web, if required
;
;  IF keyword_set(web) then begin
;     HV_WEB_TXTNOTE,progname,transfer_results,/details
;  ENDIF
  return
end
