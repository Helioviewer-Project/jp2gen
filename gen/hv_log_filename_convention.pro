;
; Guy Fawke's Day, 2009
;
; Define a logfile name convention
;
FUNCTION HV_LOG_FILENAME_CONVENTION,nickname,t1,t2,components = components
  separator = '__'
  extension = '.log'

  full1 = utc2str(anytim2utc(t1))
  date1 = utc2str(anytim2utc(t1),/date_only)
  time1 = utc2str(anytim2utc(t1),/time_only)

  full2 = utc2str(anytim2utc(t2))
  date2 = utc2str(anytim2utc(t2),/date_only)
  time2 = utc2str(anytim2utc(t2),/time_only)
  
  if keyword_set(components) then begin
     answer = {nickname:nickname,full1:full1,date1:date1,time1:time1, $
               full2:full2,date2:date2,time2:time2,$
               extension:extension,separator:separator}
  endif else begin
     answer = nickname + separator + full1 + separator + full2 + extension
  endelse

  return,answer
end
