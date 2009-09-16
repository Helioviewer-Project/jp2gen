FUNCTION JI_HV_FILENAME_CONVENTION, hvs, create = create, split = split
;
; Take the HVS header and create a filename
;
  if keyword_set(create) then begin
     if not(is_struct(hvs)) then begin
        print,' Input is not a structure.  Returning -1 '
        answer = -1
     endif else begin
        date = hvs.yy + '_' + hvs.mm + '_' + hvs.dd
        time = hvs.hh + '_' + hvs.mmm + '_' +  hvs.ss + '_' + hvs.milli
        observation =  hvs.observatory + '_' + hvs.instrument + '_' + hvs.detector + '_' + hvs.measurement
        filename = date + '__' + time + '__' + observation
        answer = filename
     endelse
  endif
;
; Take a filename and split it into its components
;
  if keyword_set(split) then begin
     z = strsplit(hvs,'_',/extract)
     answer = {yy:z[0], mm:z[1], dd:z[2], hh:z[3], mmm:z[4], ss:z[5], milli:z[6],$
               observatory:z[7], instrument:z[8], detector:z[9], measurement:z[10]}
  endif
;
;
;
  return,answer
end
