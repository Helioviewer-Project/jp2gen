;
; 4 November - WRITE out Hinode XRT color tables
;
PRO HV_XRT_WRITE_COLORTABLE_PNG,dir = dir
;
  if not keyword_set(dir) then dir = ''

; All XRT measurements have the same colortable.  Let's go with
; that for right now.
  loadct, 3, rgb_table=rgb_table

  a = findgen(1,256)
  r = reform(rgb_table[*, 0])
  g = reform(rgb_table[*, 1])
  b = reform(rgb_table[*, 2])

  ; write a color table for the given measurement name "mname"
  write_png,dir +  'xrtall_colortable.png',a,r,g,b

  return
end
