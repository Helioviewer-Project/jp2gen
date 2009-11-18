;
; 18 November 09
;
; JI_HV_LASCO_PREP2JP2
;
; Convert LASCO FITS files to JP2
; 
; Pass a start date and an end date in the form
;
; 2009/11/18
;
; and pick an instrument
;

PRO JI_HV_LASCO_PREP2JP2,ds,de,auto = auto,c2 = c2, c3 = c3
  progname = 'ji_hv_lasco_prep2jp2'

  if (anytim2tai(ds) gt anytim2tai(de)) then begin
     print,progname + ': start time after end time.  Check times passed to routine.  Stopping.'
     stop
  endif

  date_start = ds + 'T00:00:00'
  date_end = de + 'T23:59:59'

  if keyword_set(c2) then begin
     JI_HV_LASCO_C2_PREP2JP2,ds,de
  endif

  if keyword_set(c3) then begin
     JI_HV_LASCO_C3_PREP2JP2,ds,de
  endif

  return
end
