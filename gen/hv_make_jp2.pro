;
; 30 September 2010
;
; HV_MAKE_JP2
; - single simple point of entry to convert a FITS file to a JPEG2000
;   file for use with the Helioviewer Project.  Calling this
;   function with the appropriately defined variable "hvs" is
;   sufficient to create a Helioviewer-compliant JPEG2000 file.
;

PRO HV_MAKE_JP2,hvs,jp2_filename = jp2_filename, already_written = already_written
;
; get general information
;
  ginfo = CALL_FUNCTION('hvs_gen')
;
; Could also do some verification of the input here
;
; HV_VERIFY_SUFFICIENT,hvs
;
; Write the file and log file
;
  HV_WRITE_LIST_JP2,hvs,jp2_filename = jp2_filename, already_written = already_written
  if not(already_written) then begin
     log_comment = 'directory = '+ hvs.hvsi.dir + $
                   ' ; read ' + hvs.hvsi.fitsname + $
                   ' ; ' +HV_JP2GEN_CURRENT(/verbose) + $
                   ' ; at ' + systime(0) + $
                   ' ; ' + hvs.hvsi.comment
     HV_LOG_WRITE,hvs.hvsi,log_comment + ' ; wrote ' + jp2_filename
  endif else begin
     jp2_filename = ginfo.already_written
  endelse
  return
end
