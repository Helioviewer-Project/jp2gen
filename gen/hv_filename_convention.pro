;
; 16 September 2009
;
; Function to create a JP2 file name from its source HVS file, and to
; split up an input filename into its component parts
;
FUNCTION HV_FILENAME_CONVENTION, hvs, create = create, split = split, construct = construct
;
; Take the HVS header and create a filename
;
  NotGiven = (HV_STORAGE(nickname = hvs.details.nickname)).NotGiven
  if keyword_set(create) then begin
     if not(is_struct(hvs)) then begin
        print,' Input is not a structure.  Returning -1 '
        answer = -1
     endif else begin

        if tag_exist(hvs,'yy') then begin
           if hvs.yy eq '' then yy = NotGiven else yy = hvs.yy
        endif else begin
           yy = NotGiven
        endelse
        if tag_exist(hvs,'mm') then begin
           if hvs.mm eq '' then mm = NotGiven else mm = hvs.mm
        endif else begin
           mm = NotGiven
        endelse
        if tag_exist(hvs,'dd') then begin
           if hvs.dd eq '' then dd = NotGiven else dd = hvs.dd
        endif else begin
           dd = NotGiven
        endelse
        date = yy + '_' +  mm + '_' +  dd

        if tag_exist(hvs,'hh') then begin
           if hvs.hh eq '' then hh = NotGiven else hh = hvs.hh
        endif else begin
           hh = NotGiven
        endelse
        if tag_exist(hvs,'mmm') then begin
           if hvs.mmm eq '' then mmm = NotGiven else mmm = hvs.mmm
        endif else begin
           mmm = NotGiven
        endelse
        if tag_exist(hvs,'ss') then begin
           if hvs.ss eq '' then ss = NotGiven else ss = hvs.ss
        endif else begin
           ss = NotGiven
        endelse
        if tag_exist(hvs,'milli') then begin
           if hvs.milli eq '' then milli = NotGiven else milli = hvs.milli
        endif else begin
           milli = NotGiven
        endelse
        time =  hh + '_' +  mmm + '_' +   ss + '_' +  milli

        details = hvs.details
        if tag_exist(details,'observatory') then begin
           if details.observatory eq '' then observatory = NotGiven else observatory = details.observatory
        endif else begin
           observatory = NotGiven
        endelse
        if tag_exist(details,'instrument') then begin
           if details.instrument eq '' then instrument = NotGiven else instrument = details.instrument
        endif else begin
           instrument = NotGiven
        endelse
        if tag_exist(details,'detector') then begin
           if details.detector eq '' then detector = NotGiven else detector = details.detector
        endif else begin
           detector = NotGiven
        endelse
        if tag_exist(hvs,'measurement') then begin
           if hvs.measurement eq '' then measurement = NotGiven else measurement = hvs.measurement
        endif else begin
           measurement = NotGiven
        endelse
        observer =  observatory + '_' +  instrument + '_' +  detector
        observation = observer + '_' +  measurement

        if not(keyword_set(construct)) then begin
           answer = date + '__' + time + '__' + observation
        endif else begin
           if construct eq 'date' then begin
              answer = date
           endif
           if construct eq 'date+time' then begin
              answer = date + '__' + time
           endif
           if construct eq 'date+time+observation' then begin
              answer = date + '__' + time + '__' + observation
           endif
           if construct eq 'date+observation' then begin
              answer = date + '__' + observation
           endif
           if construct eq 'date+observer' then begin
              answer = date + '__' + observer
           endif
        endelse
     endelse
  endif
;
; Take a filename and split it into its components
;
  if keyword_set(split) then begin
     z = strsplit(hvs,'_',/extract)
     answer = {yy:z[0], mm:z[1], dd:z[2], hh:z[3], mmm:z[4], ss:z[5], detector:z[6],$
               observatory:z[7], instrument:z[8], detector:z[9], measurement:z[10]}
  endif
;
;
;
  return,answer
end
