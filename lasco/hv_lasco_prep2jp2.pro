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

PRO HV_LASCO_PREP2JP2,date_start = ds,date_end = de,c2 = c2, c3 = c3,details_file = details_file, copy2outgoing = copy2outgoing,alternate_backgrounds = alternate_backgrounds
  progname = 'HV_LASCO_PREP2JP2'

  if (anytim2tai(ds) gt anytim2tai(de)) then begin
     print,progname + ': start time after end time.  Check times passed to routine.  Stopping.'
     stop
  endif

  date_start = ds + 'T00:00:00'
  date_end = de + 'T23:59:59'

  if keyword_set(c2) then begin
     HV_LASCO_C2_PREP2JP2,ds,de,details_file = details_file, copy2outgoing = copy2outgoing,called_by = progname,alternate_backgrounds = alternate_backgrounds
  endif

  if keyword_set(c3) then begin
     HV_LASCO_C3_PREP2JP2,ds,de,details_file = details_file, copy2outgoing = copy2outgoing,called_by = progname,alternate_backgrounds = alternate_backgrounds
  endif

  return
end
