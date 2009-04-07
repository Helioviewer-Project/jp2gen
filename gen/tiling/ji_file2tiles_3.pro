;+
; Project     : HINODE/EIS
;
; Name        : JI_FILE2TILES
;
; Purpose     : Read and tile image files
;
; Inputs      : FILENAME = image filename
;
; Outputs     : Individual tile files
;
; Keywords    : see MK_TILES/WR_TILES
;
; Version     : Written 09-Nov-2007, Ireland (ADNET/GSFC)
;               JI_FILE2TILES based on FILE2TILES
;               Written 14-Feb-2007, Zarro (ADNET/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro ji_file2tiles_3,filename,_extra=extra,verbose=verbose,zoom_offset = zoom_offset,format = format

if is_blank(filename) then return

;-- supported format?

query=query_image(filename,type=type)
if ~query then begin
 message,'invalid image file',/cont
 return
endif

;-- start tiling

image=read_image(filename,red,green,blue)
if keyword_set(verbose) then message,'tiling '+filename,/cont
;ji_mk_tiles_3,image,red=r,green=g,blue=b,$
;   format=strlowcase(type),_extra=extra,verbose=verbose,zoom_offset = zoom_offset
ji_mk_tiles_3,image,512,red=red,green=green,blue=blue,_extra=extra,verbose=verbose,zoom_offset = zoom_offset,format = format

return & end
