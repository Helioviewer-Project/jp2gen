;
; Reprocess the last week's EIT data, and the last month's EIT data
;
PRO HV_EIT_PREP2JP2_BACKFILL
  progname = 'HV_EIT_PREP2JP2_BACKFILL'
  n = long(0)
  repeat begin
;
; Today's date
;
     get_utc,de,/ecs,/date_only
;
; Today's time in seconds
;
     get_utc,utc
     today_in_seconds = ANYTIM2TAI(utc)
     one_week_in_seconds = 7.0*24.0*60.0*60.0
     one_month_in_seconds = 4*one_week_in_seconds
;
; Now do the last month's worth of data
;
     ds = ANYTIM2CAL(today_in_seconds - one_month_in_seconds,form = 11, /date)
     HV_EIT_PREP2JP2,ds,de,prepped=prepped,called_by = progname
     HV_COPY2OUTGOING,prepped
;
; Update progress
;
     n = n + 1
     print,progname + ': completed transfer '+trim(n)
     print,progname + ': waiting one day until next backfill run.'
     wait,long(60)*long(60)*long(24)
  endrep until 1 eq 0
  return
end
