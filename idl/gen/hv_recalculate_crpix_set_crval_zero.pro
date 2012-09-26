;
; 14 December 2011
;
; Function to recalculate CRPIX values so that they are zero when
; CRVAL is non-zero.
;
FUNCTION HV_RECALCULATE_CRPIX_SET_CRVAL_ZERO,header
  wcs = fitshead2wcs(header)
  center = wcs_get_pixel(wcs, [0,0])
  return,center
end
