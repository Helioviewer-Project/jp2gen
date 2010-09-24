;
; April 13, 2010: first edit by JI of Greg Slater's file
;
; Separated out the JP2 writing part from the file selection part of
; mk_jp2000_queue
;
; This program takes the following input
;
; fitsname: source FITS file (filename only)
; img: a 2 dimensional numerical array which contains a single channel
; grayscale image
; header: the FITS header for this FITS file
;
PRO hv_aia_d2jp2, fitsname, img, hd, $
                  details_file = details_file, $ ; use an alternate details file
                  dir = dir, $ ; directory where the file was kept (may not be useful for AIA)
                  jp2_filename = jp2_filename, $ ; JP2 file name
                  already_written = already_written ; was the file already written?
;
  progname = 'hv_aia_d2jp2'
;
; Call general JP2Gen setup
;
  g = HVS_GEN()
;
; Call AIA specfic details
;
  if not(keyword_set(details_file)) then details_file = 'hvs_default_aia'
  info = CALL_FUNCTION(details_file)
;
; Convert the header to a structure if need be
;
  if not(is_struct(hd)) then hd = fitshead2struct(hd)
;
; Parse the observation time
;
  tobs = HV_PARSE_CCSDS(hd.date_obs)
;
; Directory where the FITS file came from (might not be necessary or useful for AIA)
;
  if not(keyword_set(dir)) then dir = g.notgiven
;
; All the supported measurements
;
  wave_arr = info.details[*].measurement
;
; Check that this FITS file is supported
;
  this_wave = where(wave_arr eq trim(hd.wavelnth),this_wave_count)
  if this_wave_count eq 0 then begin
     measurement = 'not_supported'
  endif else begin
     measurement = trim(hd.wavelnth)
;
; Wavelength-dependent scaling of the image
;
     lmin = where(img le info.details[this_wave].dataMin)
     if lmin[0] ne -1 then begin
        img[lmin] = info.details[this_wave].dataMin
     endif

     lmax = where(img ge info.details[this_wave].dataMax)
     if lmax[0] ne -1 then begin
        img[lmax] = info.details[this_wave].dataMax
     endif

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
; add extra tags
;
     hd = add_tag(hd,info.observatory,'hv_observatory')
     hd = add_tag(hd,info.instrument,'hv_instrument')
     hd = add_tag(hd,info.detector,'hv_detector')
     hd = add_tag(hd,measurement,'hv_measurement')
     hd = add_tag(hd,0.0,'hv_rotation')
     hd = add_tag(hd,progname,'hv_source_program')
;
; Create the hvs structure
;
     hvsi = {dir:dir,$
             fitsname:fitsname,$
             header:hd,$
             yy:tobs.yy,$
             mm:tobs.mm,$
             dd:tobs.dd,$
             hh:tobs.hh,$
             mmm:tobs.mmm,$
             ss:tobs.ss,$
             milli:tobs.milli,$
             measurement:measurement,$
             details:info}
     hvs = {img:img,hvsi:hvsi}
;
; Write the JP2 file
;
     HV_WRITE_LIST_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written
;     if not(already_written) then begin
;        HV_LOG_WRITE,hvs,'read ' + fitsname + ' ; ' +HV_JP2GEN_CURRENT(/verbose) + '; at ' + systime(0) + ' : wrote to ' + jp2_filename
;     endif else begin
;        jp2_filename = g.MinusOneString
;     endelse
  endelse
  return
end
