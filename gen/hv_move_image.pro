;
; 2011/01/05
;
; Move an image to a specified location
;
FUNCTION HV_MOVE_IMAGE,img,xcen,ycen,replacementValue = replacementValue
;
  if not(keyword_set(replacementValue)) then begin
     replacementValue = 0.0
  endif
;
  sz = size(img,/dim)
  nx = sz[0]
  ny = sz[1]
  cxImg = nx/2.0
  cyImg = ny/2.0

; displacement
  dispx = nint(xcen - cxImg)
  dispy = nint(ycen - cyImg)

; shift the image
  new = shift(img,dispx,dispy)

; Shift implements a circular shift.  Zero out the data that goes
; round in the circle
  if dispx ne 0 then begin
     if dispx lt 0 then begin
        new[nx-abs(dispx):nx-1,*] = replacementValue
     endif
     if dispx gt 0 then begin
        new[0:dispx-1,*] = replacementValue
     endif
  endif

  if dispy ne 0 then begin
     if dispy lt 0 then begin
        new[*,ny-abs(dispy):ny-1] = replacementValue
     endif
     if dispy gt 0 then begin
        new[*,0:dispy-1] = replacementValue
     endif
  endif

  return, new
end
