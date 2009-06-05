;
;
;
FUNCTION JI_HV_ERR_REPORT,err_report,filename, hvs = hvs, name = name

  if not(keyword_set(hvs)) then begin
     if not(keyword_set(name)) then name = ''
     err_location = (ji_hv_storage()).err_location
     print,err_report + filename
     incomplete = err_location + 'err.' + name + '.' + ji_systime() + '.log.sav'
     print,'Writing filename and error report to ' + incomplete
     save,filename = incomplete,filename,err_report
  endif else begin
     if not(keyword_set(name)) then name = ''
     err_location = ji_write_list_jp2_mkdir(hvs,(ji_hv_storage()).err_location)
     print,err_report + filename
     incomplete = err_location + 'err.' + name + '.log.sav'
     print,'Writing filename and header information to ' + incomplete
     save,filename = incomplete,hvs,filename,err_report
  endelse

  return,'-1'
end
