;
; 14 December 2011
;
; Test to see if the header has CRVAL values other than zero.  If so,
; then recalculate them, and make sure the header reflects and makes
; note of those changes
;
FUNCTION HV_RECALCULATE_CRPIX,inputHeader
  header = inputHeader

  ;
  ; Line feed character:
  ;
  lf = string(10b)

  ;
  ; Keep a copy of the original values of CRPIX1,2 , CRVAL1,2
  ;
  header = add_tag(header, trim(header.crval1),'hv_crval1_original')
  header = add_tag(header, trim(header.crval2),'hv_crval2_original')

  header = add_tag(header, trim(header.crpix1),'hv_crpix1_original')
  header = add_tag(header, trim(header.crpix2),'hv_crpix2_original')

  ;
  ; Run the recalculator
  ;
  if (header.crval1 ne 0) or (header.crval2 ne 0) then begin

     ; Set CRVAL to zero
     center = HV_RECALCULATE_CRPIX_SET_CRVAL_ZERO(header)

     ; CRPIX1, 2 now have different values
     header.crpix1 = center[0]
     header.crpix2 = center[1]

     ; CRVAL1, 2 are now identically zero
     header.crval1 = 0
     header.crval2 = 0

     ; Update the flag
     header = add_tag(header, 'TRUE', 'hv_recalculate_crpix')

  endif else begin
     header = add_tag(header, 'FALSE', 'hv_recalculate_crpix')
  endelse

;
; Return the header and exit
;
  return,header
end
