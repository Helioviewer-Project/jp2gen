;
; take a list of JP2 files from the main archive transfer them to a remote machine
;
;
PRO HV_JP2_TRANSFER_DIRECT,input
  progname = 'hv_jp2_transfer_direct'
;
; Get various details about the setup
;
  wby = HV_WRITTENBY()
  g = HVS_GEN()
  storage = HV_STORAGE()
;
; Transfer start-time
;
  transfer_start_time = JI_SYSTIME()

;     transfer_details = ' -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.8/inc/test_transfer/'
;
; define the transfer script
;
  transfer_details = ' -e ssh -l ' + $
                     wby.transfer.remote.user + '@' + $
                     wby.transfer.remote.machine + ':' + $
                     wby.transfer.remote.incoming + $
                     'v' + g.source.jp2gen_version + path_sep()


  return
end
