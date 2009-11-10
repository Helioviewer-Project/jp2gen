;
; Take a list of MDI files and write them out to HVS format
;
; Return the filenames
;
FUNCTION JI_MDI_WRITE_HVS,list,rootdir,int = int, mag = mag
  nickname = 'MDI'
  n = n_elements(list)
;
; Read in the first and last FITS file to create the log
; sub-directory and filename
;
  dummy = readfits(list[0],h1)
  date_start = (fitshead2struct(h1)).obt_time

  dummy = readfits(list[n_elements(list)-1],h2)
  date_end = (fitshead2struct(h2)).obt_time

  JI_HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
  filename = JI_HV_LOG_FILENAME_CONVENTION(nickname, date_start, date_end)
;
; Go through the list
;
  done = strarr(n)
  if keyword_set(int) then begin
     logfilename = 'int.' + filename
     for i = 0,n-1 do begin
        done(i) = JI_MDI_INT_WRITE_HVS2(list(i),rootdir)
        JI_HV_WRT_ASCII,done(i),subdir + logfilename,/append
     endfor
  endif
  if keyword_set(mag) then begin
     logfilename = 'mag.' + filename
     for i = 0,n-1 do begin
        done(i) = JI_MDI_MAG_WRITE_HVS2(list(i),rootdir)
        JI_HV_WRT_ASCII,done(i),subdir + logfilename,/append
     endfor
  endif

RETURN,done
END
