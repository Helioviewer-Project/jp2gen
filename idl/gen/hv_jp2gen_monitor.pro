;
; Details on how to transfer data from the production machine to the
; server
;
; Program to create a monitoring webpage for JP2Gen
;
;
PRO HV_JP2GEN_MONITOR,cadence
;
  progname = 'HV_JP2GEN_MONITOR'
  t0 = systime(0)
  count = 0
  repeat begin
;
; Wait "cadence" minutes before re-creating the web page
;
     HV_WEBPAGE, search = 'latest*.txt',filename = 'jp2gen_monitor.html',link = ['details.html'],title = 'JP2Gen: FITS to JP2 monitor'
     HV_WEBPAGE, search = 'details*.txt',filename = 'details.html',link = ['jp2gen_monitor.html'],title = 'Detailed Monitor'
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,t0,/web
     HV_WAIT,progname,cadence,/minutes,/web

  endrep until 1 eq 0

  return
end
