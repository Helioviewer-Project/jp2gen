;
; 08 April 2011
;
; HV_EUVI_PREP2JP2_DO
;
; Convert EUVI FITS files to JP2
; 
; Pass a start date and an end date in the form
;
; 2009/11/18
;

PRO HV_SECCHI_PREP2JP2,date_start = ds, $ ; date the automated processing starts
                       date_end = de, $   ; date to end automated processing starts
                       copy2outgoing = copy2outgoing,$
                       euvi = euvi,$
                       cor1 = cor1,$
                       cor2 = cor2,$
                       no_repeat = no_repeat
;
  progname = 'HV_SECCHI_PREP2JP2'
;
  timestart = systime(0)
  count = 0
  repeat begin
;
; Get today's date in UT
;
     get_utc,utc,/ecs,/date_only
     if (count eq 0) then begin
        if not(keyword_set(ds)) then ds = utc
        if not(keyword_set(de)) then de = utc + ' 23:59'
     endif else begin
        ds = utc
        de = utc
     endelse
     print,' '
     print,progname + ': Processing... ' + ds + ' to ' + de

     if keyword_set(euvi) then begin
        HV_EUVI_BY_DATE,[ds,de],prepped = prepped
        if keyword_set(copy2outgoing) then HV_COPY2OUTGOING,prepped
     endif

     if keyword_set(cor1) then begin
        HV_COR1_BY_DATE,[ds,de],prepped = prepped
        if keyword_set(copy2outgoing) then HV_COPY2OUTGOING,prepped
     endif

     if keyword_set(cor2) then begin
        HV_COR2_BY_DATE,[ds,de],prepped = prepped
        if keyword_set(copy2outgoing) then HV_COPY2OUTGOING,prepped
     endif

     if NOT(keyword_set(euvi)) and NOT(keyword_set(cor1)) and NOT(keyword_set(cor2)) then begin
        print,'No SECCHI instrument chosen.  Stopping.'
        stop
     endif
;
; Wait 15 minutes before looking for more data
;
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,timestart, more = ['examined ' + ds + ' to ' + de + '.'],/web
     HV_WAIT,progname,15,/minutes,/web

  endrep until 1 eq keyword_set(no_repeat)

  return
end
