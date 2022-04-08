; Purpose    : This routine will check the exit_status of each outgoing file into each remote machine.
;              If the exit_status of a file is successful (0) to all remote machines, then that file is deleted
;              Otherwise, the file remains in its outgoing directory.
;
; Inputs     : EXIT_STATUS = NRM x N array of transfer status values (0 for success, 1 for failure)
;              for NRM remote machines and N outgoing files.
;
;              FILES is the array containing the file path of the outgoing files to be transferred
;
; Outputs    :
;              TRANSFER_RESULTS = (NRM + 1) X N string array that details the transfer result
;              of each outgoing file to a remote machine. The last column being file_del_results
;



pro hv_jp2_tr_file_del,exit_status,files,transfer_results=transfer_results

  if n_elements(files) eq 0 then begin
    message,'Input filenames missing',/cont
    return
  endif

  ;sdir_full = file_dirname(file)
  n = n_elements(files)
  file_del_results = strarr(n)
  es_nd = size(exit_status, /N_DIM)

  if es_nd eq 1 then begin
    summed_status = exit_status
    nrm = 1
  endif else begin
    summed_status=total(exit_status,1)
    es_dim = size(exit_status, /DIM)
    nrm = es_dim[0]
  endelse

  chk=where(summed_status eq 0, count,complement=nchk,ncomplement=ncount)

  help,calls=calls
  progname=calls[0]
  output=progname + ': deleting ' +files[chk]

  if count gt 0 then begin
    file_delete, files[chk]
    print,output
    file_del_results[chk] = output
  endif

  if keyword_Set(transfer_results) then transfer_results[nrm,*]=file_del_results

end