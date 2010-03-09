;
; Program to transfer files from the outgoing directory to a remote
; location.  The program first forms a list of the subdirectories and
; files, moves those files to the remote location, and then deletes
; those files from the outgoing directory.
;
;
PRO HV_JP2_TRANSFER
  progname = 'hv_jp2_transfer'
;
; Get a list of the files in the outgoing directory
;

;
; Remove subdirectories from the list that are empty
;

;
; Connect to the remote machine and transfer files plus their structure
;

;
; Close connection to remote machine
;

;
; Remove files that have been transferred
;


  return
end
