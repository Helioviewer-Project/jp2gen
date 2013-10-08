;
; Process large amounts of TRACE data
;
; Pass in an array with dates [earlier_date, later_date]
;
;
PRO HV_TRACE_PROCESS_BACKFILL,date
  progname = 'hv_trace_process_backfill'
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
; Get the data for this day
;
; Query the TRACE catalog on an hourly basis so we don't have
; too much data in memory at any one time
     for i = 0, 22 do begin
        start_time = this_date + hourlist[i]
        end_time = this_date + hourlist[i+1]
        trace_cat, start_time, end_time, catalog
;
; Transfer the data to the Helioviwer 
;


  endrep until mjd gt mjd_end


  return
END

 

