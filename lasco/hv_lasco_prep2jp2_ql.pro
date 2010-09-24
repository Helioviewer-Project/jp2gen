;
; 18 November 09
;
; HV_LASCO_PREP2JP2
;
; Convert LASCO FITS files to JP2
; 
; Pass a start date and an end date in the form
;
; 2009/11/18
;
; and pick an instrument
;

PRO HV_LASCO_PREP2JP2_QL,date_start = ds, $ ; date the automated processing starts
                         date_end = de, $   ; date to end automated processing starts
                         c2 = c2, $         ; choose the c2 instrument
                         c3 = c3, $         ; choose the c3 instrument
                         details_file = details_file,$                     ; call to an explicit details file
                         alternate_backgrounds = alternate_backgrounds,$   ; location of the alternate backgrounds
                         copy2outgoing = copy2outgoing,$                   ; copy to the outgoing directory
                         once_only = once_only,$                           ;  if set, the time range is passed through once only
                         writtenby = writtenby
;
  progname = 'HV_LASCO_PREP2JP2_QL'
;
; Make sure at least one of C2 or C3 is called
;
  if not(keyword_set(c2)) and not(keyword_set(c3)) then begin
     print,progname + ': neither C2 or C3 chosen.  Use one of /c2 or /c3 in call to '+progname + '. Stopping.'
     stop
  endif
;
; use the default LASCO file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then begin
     if keyword_set(c2) then begin
        details_file = 'hvs_default_lasco_c2'
        progname = progname + '(C2)'
     endif
     if keyword_set(c3) then begin
        details_file = 'hvs_default_lasco_c3'
        progname = progname + '(C3)'
     endif
  endif else begin
     if keyword_set(c2) then begin
        progname = progname + '(C2)'
     endif
     if keyword_set(c3) then begin
        progname = progname + '(C3)'
     endif
  endelse
;
; Assign the default writtenby choice if no other present
;
  if not(KEYWORD_SET(writtenby)) then begin
     writtenby = 'default'
  endif
;
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname

  IF keyword_set(alternate_backgrounds) then begin
     alternate_backgrounds = info.alternate_backgrounds
     progname = progname + '(used alternate backgrounds)'
     setenv,'MONTHLY_IMAGES=' + alternate_backgrounds
;     HV_LASCO_UPDATE_ALTERNATE_BACKGROUNDS,alternate_background,info ; download the alternate backgrounds from the web
  endif    
;
  timestart = systime(0)
  count = long(0)
;
  repeat begin
;
; Get today's date in UT
;
     get_utc,utc,/ecs,/date_only
     if (count eq 0) then begin
        if not(keyword_set(ds)) then ds = utc
        if not(keyword_set(de)) then de = utc
     endif else begin
        ds = utc
        de = utc
     endelse
     print,' '
     print,progname + ': Processing... ' + ds + ' to ' + de

     if keyword_set(c2) then begin
        HV_LASCO_C2_PREP2JP2,ds,de,details_file = details_file,called_by = progname,copy2outgoing = copy2outgoing,alternate_backgrounds = alternate_backgrounds,report=report;,writtenby = writtenby
     endif

     if keyword_set(c3) then begin
        HV_LASCO_C3_PREP2JP2,ds,de,details_file = details_file,called_by = progname,copy2outgoing = copy2outgoing,alternate_backgrounds = alternate_backgrounds,report=report;,writtenby = writtenby
     endif

     if NOT(keyword_set(c2)) and NOT(keyword_set(c3)) then begin
        print,'No coronagraph chosen.  Stopping'
        stop
     endif
;
; Wait 15 minutes before looking for more data
;
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,timestart, more = ['examined ' + ds + ' to ' + de + '.',report],/web
     HV_WAIT,progname,15,/minutes,/web

  endrep until 1 eq keyword_set(once_only)

  return
end
