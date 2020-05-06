;
; Transfer JP2 files to remote machine once every "cadence" minutes
;
; This program also defines the value of 'write_this', which is used
; everywhere to define the directories where the files are writte to
; and read from.
PRO HV_JP2_TRANSFER_SCHEDULE,cadence,write_this,_extra = _extra
  progname = 'HV_JP2_TRANSFER_SCHEDULE'
  timestart = systime(0)
  n = long(0)
  repeat begin
     hv_jp2_transfer,write_this,ntransfer = ntransfer,/web, _extra = _extra
     n = n + long(1)
     HV_REPEAT_MESSAGE,progname,n,timestart,/web,more = ['Number of files transferred = ' + trim(ntransfer)]
     HV_WAIT,progname,cadence,/minutes,/web
  endrep until 1 eq 0
  return
end
