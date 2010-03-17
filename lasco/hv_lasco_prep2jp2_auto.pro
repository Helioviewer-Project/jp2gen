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

PRO HV_LASCO_PREP2JP2_AUTO,c2 = c2, c3 = c3,details_file = details_file,$
                           alternate_backgrounds = alternate_backgrounds,$
                           copy2outgoing = copy2outgoing
  progname = 'HV_LASCO_PREP2JP2_AUTO'
;
;
;
  IF keyword_set(alternate_backgrounds) then begin
     progname = progname + '(used alternate backgrounds from ' + alternate_backgrounds + ')'
     setenv,'MONTHLY_IMAGES=' + alternate_backgrounds
  endif
     
;
;
;
  repeat begin
;
; Get today's date in UT
;
     get_utc,utc,/ecs,/date_only
     ds = utc
     de = utc
     print,' '
     print,progname + ': Processing... ' + ds + ' to ' + de

     if keyword_set(c2) then begin
        HV_LASCO_C2_PREP2JP2,ds,de,details_file = details_file,called_by = progname,copy2outgoing = copy2outgoing
     endif

     if keyword_set(c3) then begin
        HV_LASCO_C3_PREP2JP2,ds,de,details_file = details_file,called_by = progname,copy2outgoing = copy2outgoing
     endif

     if NOT(keyword_set(c2)) and NOT(keyword_set(c3)) then begin
        print,'No coronagraph chosen.  Stopping'
        stop
     endif
;
; Wait 15 minutes before looking for more data
;
     print,'Fixed wait time of 30 minutes now progressing.'
     wait,60*30.0

  endrep until 1 eq 0

  return
end
