;
; 2009/10/28
;
; write a logfile
;

PRO HV_LOG_WRITE,subdir,filename,prepped,verbose = verbose
  wrt_ascii,prepped,subdir + filename
  if verbose then print,'HV_LOG_WRITE wrote a log file: '+ subdir + filename + ' at ' + systime(0)
  return
end
