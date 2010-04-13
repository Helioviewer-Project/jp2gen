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
PRO hv_aia_d2jp2, fitsname, img, header, $
                  details_file = details_file, $ ; use an alternate details file
                  dir = dir, $ ; directory where the file was kept (may not be useful for AIA)
                  jp2_filename = jp2_filename, $ ; JP2 file name
                  already_written = already_written ; was the file already written?
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
  if not(is_struct(header)) then header = fitshead2struct(header)
;
; Parse the observation time
;
  tobs = HV_PARSE_CCSDS(header.date_obs)
;
; Directory where the FITS file came from (might not be necessary or useful for AIA)
;
  if not(keyword_set(dir)) then begin dir = g.notgiven
;
; Create the hvs structure
;
  hvs = {dir:dir,$
         fitsname:fitsname,$
         img:img,$
         header:header,$
         measurement:wave_arr(this_wave),$
         yy:,tobs.yy,$
         mm:,tobs.mm,$
         dd:,tobs.dd,$
         hh:,tobs.hh,$
         mmm:,tobs.mmm,$
         ss:,tobs.ss,$
         milli:,tobs.milli,$
         details:info}
;
; All the supported measurements
;
  wave_arr = info.details[*].measurement
;
; Check that this FITS file is supported
;
  this_wave = where(wave_arr eq header.wavelnth,this_wave_count)
  if this_wave_count eq 0 then begin
     print,progname + ': this wavelength is not supported by JP2Gen.'
     print,progname + ': requested wavelength = ' + this_wave
     HV_LOG_WRITE,hvs,'read ' + fitsname + ' ; ' +HV_JP2GEN_CURRENT(/verbose) + '; at ' + systime(0) + ' requested wavelength  = ' + this_wave + ' is not supported by JP2Gen'
     jp2_filename = g.na
     already_written = 0
  endif else begin
;
; Write the JP2 file
;
     HV_WRITE_LIST_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written
     if not(already_written) then begin
        HV_LOG_WRITE,hvs,'read ' + fitsname + ' ; ' +HV_JP2GEN_CURRENT(/verbose) + '; at ' + systime(0) + ' : wrote to ' + jp2_filename
     endif
      
  endelse
  return
end
