;
; Process large amounts of SECCHI data
;
; Pass in an array with dates [earlier_date, later_date]
;
;
PRO HV_SECCHI_PROCESS_BACKFILL,date,cor1=cor1, cor2=cor2, euvi=euvi
  progname = 'hv_secchi_process_backfill'
;
;  Check that the date is valid.
;
  if (n_elements(date) eq 1) or (n_elements(date) gt 2) then message, $
     'DATE must have 2 elements'
  message = ''
  utc = anytim2utc(date, errmsg=message)
  if message ne '' then message, message
;
;
;
  mjd_start = date2mjd(nint(strmid(date[0],0,4)),nint(strmid(date[0],5,2)),nint(strmid(date[0],8,2)))
  mjd_end   = date2mjd(nint(strmid(date[1],0,4)),nint(strmid(date[1],5,2)),nint(strmid(date[1],8,2)))
  if mjd_start gt mjd_end then begin
     print,progname + ': start date must be earlier than end date since this program works backwards from earlier times'
     print,progname + ': stopping.'
     stop
  endif
;
;
;
  mjd = mjd_start - 1
  repeat begin
     ; go forward one day
     mjd = mjd + 1

     ; calculate the year / month / date
     mjd2date,mjd,y,m,d

     yyyy = trim(y)
     if m le 9 then mm = '0'+trim(m) else mm = trim(m)
     if d le 9 then dd = '0'+trim(d) else dd = trim(d)

     this_date = yyyy+'-'+mm+'-'+dd
;
; Start
;
     timestart = systime()
     print,' '
     print,systime() + ': ' + progname + ': Processing all files on '+date
;
; Pick an instrument
;
     if keyword_set(cor1) then begin 
        print,systime() + ': ' + progname + ': COR1'
        HV_COR1_BY_DATE, this_date, /copy2outgoing, /recalculate_crpix
     endif
     if keyword_set(cor2) then begin
        print,systime() + ': ' + progname + ': COR2'
        HV_COR2_BY_DATE, this_date, /copy2outgoing, /recalculate_crpix
     endif
     if keyword_set(euvi) then begin
        print,systime() + ': ' + progname + ': EUVI'
        HV_EUVI_BY_DATE, this_date, /copy2outgoing, /recalculate_crpix
     endif
;
; Transfer to the helioviewer server
;
;     hv_jp2_transfer,sdir = 

  endrep until mjd gt mjd_end


  return
END

 

