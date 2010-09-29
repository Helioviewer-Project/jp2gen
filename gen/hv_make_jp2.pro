;
;
;

PRO HV_MAKE_JP2,hvs,jp2_filename = jp2_filename, already_written = already_written
;
; get general information
;
  ginfo = CALL_FUNCTION('hvs_gen')
;
; Could also do some verification of the input here
;
; HV_VERIFY_SUFFICIENT,hvs
;
; Write the file and log file
;
  HV_WRITE_LIST_JP2,hvs,jp2_filename = jp2_filename, already_written = already_written
  if not(already_written) then begin
     log_comment = 'read ' + ff(ss(i)) + $
                   ' ; ' +HV_JP2GEN_CURRENT(/verbose) + $
                   ' ; at ' + systime(0)
     HV_LOG_WRITE,hvs.hvsi,log_comment + ' ; wrote ' + jp2_filename
  endif else begin
     jp2_filename = ginfo.already_written
  endelse
  return
end
