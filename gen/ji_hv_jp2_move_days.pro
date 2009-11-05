;
; Move a whole set of days from one place to another.
;

PRO JI_HV_JP2_MOVE_DAYS,nickname,date_start,date_end
  oidm = JI_HV_OIDM2(nickname)
  storage = JI_HV_STORAGE()
  date_start_dmy = nint(strsplit(date_start,'/',/extract))
  date_end_dmy = nint(strsplit(date_end,'/',/extract))
  current_date = date2mjd(date_start_dmy[0],date_start_dmy[1],date_start_dmy[2])
  while current_date le date2mjd(date_end_dmy[0],date_end_dmy[1],date_end_dmy[2]) do begin
     mjd2date,current_date,yy,mm,dd
     yy = trim(yy)
     if mm le 9 then begin
        mm = '0' + trim(mm)
     endif else begin
         mm = trim(mm)
      endelse
     if dd le 9 then begin
        dd = '0' + trim(dd)
     endif else begin
        dd = trim(dd)
     endelse
     hvs = {observatory:oidm.observatory,$
            instrument:oidm.instrument,$
            detector:oidm.detector,$
            measurement:'',$
            yy:yy, mm:mm, dd:dd}
     source = JI_WRITE_LIST_JP2_MKDIR(hvs,storage.jp2_location)
     JI_HV_JP2_MOVE_SCRIPT,nickname, source, '~/ireland/hv/incoming',hvs
     current_date = current_date + 1
  endwhile
  return
end
