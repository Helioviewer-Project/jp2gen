;
; 16 September 2009
;
; Function to create a JP2 file name from its source HVS file, and to
; split up an input filename into its component parts
;
FUNCTION HV_DBNAME_CONVENTION, hvs, create = create
;
; Take the HVS header and create a db filename
;
  NotGiven = (HV_STORAGE(nickname = hvs.details.nickname)).NotGiven
  if keyword_set(create) then begin
     if not(is_struct(hvs)) then begin
        print,' Input is not a structure.  Returning -1 '
        answer = -1
     endif else begin
;
; Date
;
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
;
; Nickname + measurement
;
        details = hvs.details
        if tag_exist(details,'nickname') then begin
           if details.nickname eq '' then nickname = NotGiven else nickname = details.nickname
        endif else begin
           nickname = NotGiven
        endelse

        if tag_exist(hvs,'measurement') then begin
           if hvs.measurement eq '' then measurement = NotGiven else measurement = hvs.measurement
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
