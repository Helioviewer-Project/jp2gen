;
; 5 may 2010
;
PRO HV_JP2_TRANSFER_FROM_ARCHIVE,nickname,measurement,ds,de,$
                                 directory = directory,$
                                 details_file = details_file
;
  storage = HV_STORAGE()
;
; Get the information
;
  nname = ji_txtrep(nickname,'-','_')
  if not(keyword_set(details_file)) then begin
     info = CALL_FUNCTION('hvs_default_' + strlowcase(nname))
  endif
;
; Get the directory
; 
  if not(keyword_set(directory)) then begin
     directory = storage.hvr_jp2
  endif
;
; Get the requested measurements
;
  if strlowcase(measurement[0]) eq 'all' then begin
     m = info.details[*].measurement
  endif
;
; Go through all the measurements
;
  end_tai = anytim2tai(de)
  one_day = 24.0*60.0*60.0 ; one day in seconds
  nm = n_elements(m)
  for i = 0,nm-1 do begin
;
; Go through every day requested
;
     tai = anytim2tai(ds)
     repeat begin
;
; Get year/month/day
;
        a = tai2utc(tai,/external)
        
        yyyy = trim(a.year)
        
        if (a.month le 9) then begin
           mm = '0' + trim(a.month)
        endif else begin
           mm = trim(a.month)
        endelse

        if (a.day le 9) then begin
           dd = '0' + trim(a.day)
        endif else begin
           dd = trim(a.day)
        endelse
;
; Construct the directory
;
        sdir = expand_tilde(directory) + $
               nickname + path_sep() + $
               m[i] + path_sep() + $
               yyyy + path_sep() + $
               mm + path_sep() + $
               dd + path_sep()
        HV_JP2_TRANSFER,sdir = sdir

        tai = tai + one_day
     endrep until (tai gt end_tai)

  endfor


  return
end
