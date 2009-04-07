;
; ji_hv_find_embed.pro
;
;
FUNCTION ji_hv_find_embed,apph,scale,nx,ny
;
; get the number of scales available
;
  sc = n_elements(apph)
;
; find the first scale in the hierarchy less than the scale of the
; image
;
  repeat begin
     sc = sc - 1
  endrep until( apph(sc) le scale )
  f1 = scale/apph(sc)
  f2 = scale/apph(sc+1)

  c1 = abs(1.0-f1)
  c2 = abs(1.0-f2)

  if (c1 lt c2) then begin
     frescale = f1
     if ( (nint(frescale*nx) mod 2) eq 1) then begin
        hv_xlen = nint(frescale*nx) -1
        hv_ylen = nint(frescale*ny) -1
        frescale = float(hv_xlen)/float(nx)
     endif
     nx_embed = 2*nx
     ny_embed = 2*ny
  endif else begin
     frescale = f2
     if ( (nint(frescale*nx)mod 2) eq 1) then begin
        hv_xlen = nint(frescale*nx) -1
        hv_ylen = nint(frescale*ny) -1
        frescale = float(hv_xlen)/float(nx)
     endif
     nx_embed = nx
     ny_embed = ny
     sc = sc+1
  endelse
;
; re-scaling factor
;
;  frescale = scale/apph(sc)
;
; return all the properties we need
;
  return, {frescale:frescale,$
           sc:sc,$
           hv_xlen:nint(frescale*nx),$
           hv_ylen:nint(frescale*ny),$
           nx_embed: nx_embed,$
           ny_embed: ny_embed}
end
