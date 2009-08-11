;+
; Project     : HINODE/EIS
;
; Name        : JI_MK_TILES
;
; Purpose     : Make zoom tiles for image
;
; Inputs      : IMAGE = 2-d byte image
;               TSIZE = tile size [def=256]
;
; Outputs     : Individual tile files
;
; Keywords    : See WR_TILES
;
; Version     : Written 09-Nov-2007, Ireland (ADNET/GSFC)
;               JI_MK_TILES based on MK_TILES
;               Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro ji_mk_tiles_3,image,tsize,_extra=extra,zoom_offset = zoom_offset,zoom_base = zoom_base,zoom_max = zoom_max,$
                scale = km_per_px, origin = origin,format = format,red=red,green=green,blue=blue

;-- check inputs

if not(keyword_set(zoom_max)) then begin
   zoom_max = 19
endif

sz=size(image)
if (size(image,/type) ne 1) then begin
 message,'input image must be 3-D byte array',/cont
 return
endif

n1=sz[1] & n2=sz[2]
if (n1 ne n2) then begin
 message,'input image must be square',/cont
 return
endif

nsize=exponent(n1,2)
if nsize eq 0 then begin
 message,'input image size must be a power of 2',/cont
 return
endif

;-- check tiling

if is_number(tsize) then tsize=fix(tsize) else tsize=256

if (tsize eq 512) then begin
   zoom_level_tilesize_correction = 1
endif else begin
   zoom_level_tilesize_correction = 0
endelse

if (tsize gt n1) then begin
 message,'tile size must be less than image size',/cont
 return
endif

if exponent(tsize,2) lt 1 then begin
 message,'tile size must be a power of 2',/cont
 return
endif

;-- format for the zoom, x,y tile numbers

if is_blank(trimfmt) then trimfmt='(i02)'

;-- zoom offset

if not(keyword_set(zoom_offset)) then zoom_offset = 10

;
; images that we send to the tiler should be no less than this size
;
min_nsize = 2*tsize

;-- start tiling at the biggest length-scale

i=0l & i2=1
nsize=tsize
repeat begin
 i=i+1l
 if (nsize lt min_nsize) then begin
    sub_image = rebin(image,nsize,nsize,/sample)
    tile = bytarr(min_nsize,min_nsize)
    tile(min_nsize/2 - nsize/2:min_nsize/2 + nsize/2 -1, min_nsize/2 - nsize/2:min_nsize/2 + nsize/2 -1) = sub_image(*,*)
    zoom = trim(zoom_offset-i+1,trimfmt)
    zoom_now = zoom_offset-i+1-zoom_level_tilesize_correction
    zoom_tilesize_corrected = trim(zoom_now,trimfmt)
    scale = 2.0d0^(zoom-zoom_base)*km_per_px
;    ji_wr_tiles_hvcs_3,tile,i2+1,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = [-min_nsize/2,min_nsize/2]*scale,format = format,red=red,green=green,blue=blue
    ji_wr_tiles_hvcs_4,tile,i2+1,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = [-min_nsize/2,min_nsize/2]*scale,format = format,red=red,green=green,blue=blue
    nsize=nsize*2l
    i2=2^i 
 endif else begin
    tile=rebin(image,nsize,nsize,/sample)
    zoom = trim(zoom_offset-i+1,trimfmt)
    zoom_now = zoom_offset-i+1-zoom_level_tilesize_correction
    zoom_tilesize_corrected = trim(zoom_now,trimfmt)
    scale = 2.0d0^(zoom-zoom_base)*km_per_px
;    ji_wr_tiles_hvcs_3,tile,i2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
    ji_wr_tiles_hvcs_4,tile,i2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
    nsize=nsize*2l
    i2=2^i 
 endelse
endrep until( (nsize gt n1) )

;-- create single tiles which have even bigger length-scales

if (zoom_max gt zoom_offset) then begin
   for i = zoom_offset+1,zoom_max do begin
      tsize = min_nsize
      l = tsize/2^(i-zoom_offset)
      if (l lt 2) then begin
         tile = bytarr(tsize,tsize)
         zoom = trim(i,trimfmt)
         zoom_tilesize_corrected = trim(i-zoom_level_tilesize_correction,trimfmt)
         scale = 2.0d0^(zoom-zoom_base-zoom_level_tilesize_correction)*km_per_px
         origin = [-tsize/2,tsize/2]*scale
;         ji_wr_tiles_hvcs_3,tile,2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
         ji_wr_tiles_hvcs_4,tile,2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
      endif else begin
         l = l/2
         img = rebin(image,l,l,/sample)
         tile = bytarr(tsize,tsize)
         tile(tsize/2 - l/2 : tsize/2 + l/2 -1, tsize/2 - l/2 : tsize/2 + l/2 -1 ) = img(*,*)
         zoom = trim(i,trimfmt)
         zoom_tilesize_corrected = trim(i-zoom_level_tilesize_correction,trimfmt)
         scale = 2.0d0^(zoom-zoom_base-zoom_level_tilesize_correction)*km_per_px
         origin = [-tsize/2,tsize/2]*scale
;         ji_wr_tiles_hvcs_3,tile,2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
         ji_wr_tiles_hvcs_4,tile,2,_extra=extra,zoom=zoom_tilesize_corrected,scale = scale, origin = origin,format = format,red=red,green=green,blue=blue
      endelse
   endfor
endif


return & end
