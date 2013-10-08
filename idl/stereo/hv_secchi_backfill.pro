;
; SECCHI backfill process
;
; calls Bill Thompson's version of SCC_GETBKGIMG to get backgrounds
; in preference to the version in Solarsoft.  Use HV_SECCHI_BACKFILL
; to create SECCHI images when better backgrounds are available.
;
PRO HV_SECCHI_BACKFILL,date, $                                       ; date to end automated processing starts
                       details_file = details_file,$                 ; call to an explicit details file
                       copy2outgoing = copy2outgoing,$               ; copy to the outgoing directory
                       euvi = euvi,$
                       cor1 = cor1,$
                       cor2 = cor2
                       
;
; Call Bill Thompson's version of SCC_GETBKGIMG
;
;wby = HV_WRITTENBY()
;jp2gen = wby.local.jp2gen
;command = jp2gen + path_sep() + 'idl/stereo' + path_sep() + 'from_wtthompson_scc_getbkgimg.pro'
;result = EXECUTE( '.r '+command)
;@from_wtthompson_scc_getbkgimg.pro
;
  progname = 'hv_secchi_backfill'
  count = 0
  timestart = systime()
  print,' '
  print,systime() + ': ' + progname + ': Processing all files between '+date[0]+' and '+date[1]

  if keyword_set(cor1) then begin 
     print,systime() + ': ' + progname + ': COR1'
     HV_COR1_BY_DATE,date, copy2outgoing = copy2outgoing,/recalculate_crpix
  endif
  if keyword_set(cor2) then begin
     print,systime() + ': ' + progname + ': COR2'
     HV_COR2_BY_DATE,date, copy2outgoing = copy2outgoing,/recalculate_crpix
  endif
  if keyword_set(euvi) then begin
     print,systime() + ': ' + progname + ': EUVI'
     HV_EUVI_BY_DATE,date, copy2outgoing = copy2outgoing,/recalculate_crpix
  endif

end
