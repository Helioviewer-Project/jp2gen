;
; 9 October - WRITE out TRACE color tables
;
PRO HV_TRACE_WRITE_COLORTABLE_PNG,dir = dir
;
  if not keyword_set(dir) then dir = ''
  inst = ['TRACE']
  measurements = [171, 195, 284, 1216, 1550, 1600, 1700, -1000]

;  set_plot,'z'
  for j = 0,n_elements(measurements)-1 do begin
     a = findgen(1,256)
     if measurements[j] ne -1000 then begin
        trace_colors,measurements[j],r,g,b
        mname = trim(measurements[j])
     endif else begin
        loadct, 0, rgb_table=rgb_table
        r = reform(rgb_table[*, 0])
        g = reform(rgb_table[*, 1])
        b = reform(rgb_table[*, 2])
        mname = 'WL'
     endelse
     write_png,dir + mname + '_colortable.png',a,r,g,b
  endfor
  set_plot,'x'

  return
end
