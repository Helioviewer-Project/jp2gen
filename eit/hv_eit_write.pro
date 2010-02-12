;
; 16 may 2008
;
; 
;
FUNCTION HV_EIT_WRITE,eit_start,eit_end,rootdir,details
  progname = 'HV_EIT_WRITE'
;
; Create the subdirectory for the log file.
;
  HV_LOG_CREATE_SUBDIRECTORY,details.nickname,date = eit_start,subdir = subdir
;
; Create the logfilename
;
  logfilename = subdir + HV_LOG_FILENAME_CONVENTION(details.nickname,eit_start,eit_end)
;
; OLD as of 3 April 2009
;outfile = eit_img_timerange_081111(dir=rootdir,start=eit_start,end=eit_end,/hvs,/write_jp2)
;
  EIT_IMG_TIMERANGE_1,dir_im=rootdir,start=eit_start,end=eit_end,hv_write = logfilename,hv_count = hv_count,hv_details = details
;
; remove the null files
;
;  w = where(outfile ne '-1', count)
;  if count ge 1 then begin
;    return,outfile(w)
;  endif else begin
;     return,['-1']
;  endelse
  return,hv_count
end
