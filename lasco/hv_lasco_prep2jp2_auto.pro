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

PRO HV_LASCO_PREP2JP2_AUTO,c2 = c2, c3 = c3,details_file = details_file
  progname = 'HV_LASCO_PREP2JP2_AUTO'
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
        HV_LASCO_C2_PREP2JP2,ds,de,details_file = details_file,called_by = progname
     endif

     if keyword_set(c3) then begin
        HV_LASCO_C3_PREP2JP2,ds,de,details_file = details_file,called_by = progname
     endif

     if NOT(keyword_set(c2)) and NOT(keyword_set(c3)) then begin
        print,'No coronagraph chosen.  Stopping'
        stop
     endif

  endrep until 1 eq 0

  return
end
