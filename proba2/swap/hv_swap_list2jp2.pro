;
; 18 November 2010
;
; Version 1 of conversion of SWAP data to JP2
;
PRO hv_swap_list2jp2,list,$
                    details_file = details_file,$ ; SWAP details file
                    copy2outgoing = copy2outgoing,$ ; Copy the files to an outgoing directory
                    called_by = called_by,$ ; calling program (if any)
                    transfer_direct = transfer_direct ; transfer JP2 files from local to remote direct from original JP2 archive.
  progname = 'hv_swap_list2jp2'
;
; use the default AIA file is no other one is specified
;
  if not(keyword_set(details_file)) then begin
     info = CALL_FUNCTION('hvs_default_swap')
  endif else begin
     info = CALL_FUNCTION(details_file)
  endelse
  nickname = info.nickname
;
; Storage
;
  storage = HV_STORAGE(nickname = info.nickname)
;
; get general information
;
  g = HVS_GEN()
;
; Get contact details
;
  wby = HV_WRITTENBY()
;
; If called_by information is given, pass it along.  Otherwise, just
; use this program name
;
;  if keyword_set(called_by) then begin
;     info = add_tag(info,called_by,'called_by')
;  endif else begin
;     info = add_tag(info,progname,'called_by')
;  endelse
;
; All the supported measurements
;
  wave_arr = info.details[*].measurement
;
; Number of elements in the list
;
  nl = n_elements(list)
  prepped = strarr(nl)
;
; Get the fitsnames
;
  for ii = 0,nl-1 do begin
     fullname = list[ii]         ; get the full directory and filename
     z = strsplit(fullname,path_sep(),/extract) ; split up to get filename
     nz = n_elements(z)
     fitsname = z[nz-1]
;
; Read in the next fits file
;
     img = readfits(fullname,hd)   ; get image and data
     hd = fitshead2struct(hd)
;
; Check that this FITS file is supported
;
     this_wave = where(wave_arr eq trim(hd.wavelnth),this_wave_count)
     measurement = trim(hd.wavelnth)
;
; Construct an HVS
;
     tobs = HV_PARSE_CCSDS(hd.date_obs)
     exptime = hd.exptime
;
; SWAP image scaling goes here
;
     img = (img*info.details[this_wave].dataExptime/exptime > (info.details[this_wave].dataMin)) < info.details[this_wave].dataMax

     if info.details[this_wave].dataScalingType eq 0 then begin
        img = bytscl(img,/nan)
     endif
     if info.details[this_wave].dataScalingType eq 1 then begin
        img = bytscl(sqrt(img),/nan)
     endif
     if info.details[this_wave].dataScalingType eq 3 then begin
        img = bytscl(alog10(img),/nan)
     endif
;
; Add some Helioviewer Project tags.  Must begin with 'HV_'
;
     hd = add_tag(hd,info.observatory,'hv_observatory')
     hd = add_tag(hd,info.instrument,'hv_instrument')
     hd = add_tag(hd,info.detector,'hv_detector')
     hd = add_tag(hd,measurement,'hv_measurement')
     hd = add_tag(hd,0.0,'hv_rotation')
     hd = add_tag(hd,progname,'hv_source_program')
;
; create the hvs structure
;
     hvsi = {dir:dir,$
             fitsname:fitsname,$
             header:header,$
             comment:'',$
             yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli,$
             measurement:this_wave,$
             details:details}
     hvs = {img:img,hvsi:hvsi}
;
; Write a Helioviewer compliant JP2 file
;
     HV_MAKE_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written


  endfor

  RETURN
END
