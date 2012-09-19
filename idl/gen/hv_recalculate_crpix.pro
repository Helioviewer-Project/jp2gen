;
; 14 December 2011
;
; Test to see if the header has CRVAL values other than zero.  If so,
; then recalculate them, and make sure the header reflects and makes
; note of those changes
;
FUNCTION HV_RECALCULATE_CRPIX,inputHeader
  header = inputHeader
  if (header.crval1 ne 0) or (header.crval2 ne 0) then begin
     center = HV_RECALCULATE_CRPIX_SET_CRVAL_ZERO(header)
                                ;wcs = fitshead2wcs(header)
                                ;center = wcs_get_pixel(wcs, [0,0])
     header.crpix1 = center[0]
     header.crpix2 = center[1]
     crvalOriginal = 'Original values: CRVAL1='+trim(header.crval1)+','+'CRVAL2='+trim(header.crval2)
     tag_value = 'function hv_recalculate_crpix was used to recalculate CRPIX* so that CRVAL* values are identically zero. '+crvalOriginal
     if tag_exist(header,'hv_comment') then begin
        header = rep_tag_val(header,header.hv_comment + ' : ' + tag_value,'hv_comment')
     endif else begin
        header = add_tag(header,tag_value,'hv_comment')
     endelse
     header.crval1 = 0
     header.crval2 = 0
  endif
  return,header
end
