;
; 16 September 2009
;
; Function to create a JP2 file name from its source HVS file, and to
; split up an input filename into its component parts
;
FUNCTION HV_DBNAME_CONVENTION, hvsi, create = create
;
; Take the HVS header and create a db filename
;
  print, HV_STORAGE(hvsi.write_this, nickname = hvsi.details.nickname)
  NotGiven = (HV_STORAGE(hvsi.write_this, nickname = hvsi.details.nickname)).NotGiven
  if keyword_set(create) then begin
     if not(is_struct(hvsi)) then begin
        print,' Input is not a structure.  Returning -1 '
        answer = -1
     endif else begin
;
; Date
;
        if tag_exist(hvsi,'yy') then begin
           if hvsi.yy eq '' then yy = NotGiven else yy = hvsi.yy
        endif else begin
           yy = NotGiven
        endelse
        if tag_exist(hvsi,'mm') then begin
           if hvsi.mm eq '' then mm = NotGiven else mm = hvsi.mm
        endif else begin
           mm = NotGiven
        endelse
        if tag_exist(hvsi,'dd') then begin
           if hvsi.dd eq '' then dd = NotGiven else dd = hvsi.dd
        endif else begin
           dd = NotGiven
        endelse
        date = yy + '_' +  mm + '_' +  dd
;
; Nickname + measurement
;
        details = hvsi.details
        if tag_exist(details,'nickname') then begin
           if details.nickname eq '' then nickname = NotGiven else nickname = details.nickname
        endif else begin
           nickname = NotGiven
        endelse

        if tag_exist(hvsi,'measurement') then begin
           if hvsi.measurement eq '' then measurement = NotGiven else measurement = hvsi.measurement
        endif else begin
           measurement = NotGiven
        endelse
;
; Construct the database name
;
        answer = date + '__' + nickname + '__' + measurement + '__db.csv'
     endelse
  endif
  return,answer
end
