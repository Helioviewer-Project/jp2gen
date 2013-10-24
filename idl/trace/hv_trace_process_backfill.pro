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
; Get the dates
;
  mjd_start = date2mjd(nint(strmid(date[0],0,4)),nint(strmid(date[0],5,2)),nint(strmid(date[0],8,2)))
  mjd_end   = date2mjd(nint(strmid(date[1],0,4)),nint(strmid(date[1],5,2)),nint(strmid(date[1],8,2)))
  if mjd_start gt mjd_end then begin
     print,progname + ': start date must be earlier than end date since this program works backwards from earlier times'
     print,progname + ': stopping.'
     stop
  endif
;
; Hour list
;
  hourlist = strarr(25)
  for i = 0, 24 do begin
     if i le 9 then begin
        hr = '0' + trim(i)
     endif else begin
        hr = trim(i)
     endelse
     hourlist[i] = hr + ':00:00'
  endfor
  hourlist[24] = '23:59:59'

;
; Main loop
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
     print,systime() + ': ' + progname + ': Processing all files on '+this_date
;
; Get the data for this day
;
; Query the TRACE catalog on an hourly basis so we don't have
; too much data in memory at any one time
     for i = 0, 23 do begin

        ; Start and the end times
        start_time = this_date + ' ' + hourlist[i]
        end_time = this_date + ' ' + hourlist[i+1]

        ; Query the catalog
        trace_cat, start_time, end_time, catalog

        ; Convert the catalog entries to file names
        trace_cat2data,catalog,files,-1,/filedset

        ; Send the files list, then prep the data and write a JP2 file for each of the files
        HV_TRACE_PREP,files, copy2outgoing=copy2outgoing
     endfor

  endrep until mjd ge mjd_end


  return
END

