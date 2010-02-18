;
; Take a list of MDI files and write them out to HVS format
;
; Return the filenames
;
FUNCTION HV_MDI_WRITE_HVS,list,rootdir,int = int, mag = mag,details= details
  nickname = details.nickname
  n = long(n_elements(list))
;
; Read in the first and last FITS file to create the log
; sub-directory and filename
;
  dummy = readfits(list[0],h1)
  hs1 = fitshead2struct(h1)
  if tag_exist(hs1,'obt_time') then begin
     date_start = hs1.obt_time
  endif else begin
     date_start = hs1.t_obs
  endelse

  dummy = readfits(list[n_elements(list)-1],h2)
  hs2 = fitshead2struct(h2)
  if  tag_exist(hs2,'obt_time') then begin
     date_end = hs2.obt_time
  endif else begin
     date_end = hs2.t_obs
  endelse

  HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
  filename = HV_LOG_FILENAME_CONVENTION(nickname, date_start, date_end)
;
; Go through the list
;
  done = strarr(n)
  if keyword_set(int) then begin
     logfilename = 'int.' + filename
     for i = long(0),n-long(1) do begin
        done(i) = HV_MDI_INT_WRITE_HVS2(list(i),rootdir,details=details)
        HV_WRT_ASCII,done(i),subdir + logfilename,/append
     endfor
  endif
  if keyword_set(mag) then begin
     logfilename = 'mag.' + filename
     for i = long(0),n-long(1) do begin
        done(i) = HV_MDI_MAG_WRITE_HVS2(list(i),rootdir,details=details)
        HV_WRT_ASCII,done(i),subdir + logfilename,/append
     endfor
  endif

RETURN,done
END
