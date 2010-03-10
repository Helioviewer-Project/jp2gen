;
; Transfer JP2 files to remote machine once every "cadence" minutes
;
PRO HV_JP2_TRANSFER_SCHEDULE,cadence,transfer_details = transfer_details
  progname = 'HV_JP2_TRANSFER_SCHEDULE'
  n = long(0)
  repeat begin
     hv_jp2_transfer,'EIT',transfer_details = transfer_details
     n = n + 1
     print,progname + ': completed transfer '+trim(n) + ' at ' + systime(0)
     print,progname + ': waiting '+trim(cadence) + ' minutes until next.'
     wait,long(60)*long(cadence)
  endrep until 1 eq 0
  return
end
