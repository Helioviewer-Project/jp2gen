;
;+
; Takes a list of input .hvs.sav files, or a single HVS variable,
; creates a new subdirectory if need be,
; and calls ji_write_jp2 to write the jp2 file
; in that directory
;
; 2009/08/07 - change to call ji_write_jp2_lwg.pro (which does no
;              rescaling or recentering)
;
;-
PRO HV_WRITE_LIST_JP2,hvs,jp2_filename = jp2_filename,already_written = already_written, overwrite = overwrite
  progname = 'hv_write_list_jp2'
;
; Check for overwriting
;
  if not(keyword_set(overwrite)) then overwrite = 0
;
; Check if we have already written this JP2 file
;
  HV_DB,hvs.hvsi,/check_fitsname_only,already_written = already_written
;
; if new, then write it and update the database for this day
;
  if (NOT(already_written) or overwrite) then begin
     details = hvs.hvsi.details
     storage = HV_STORAGE(nickname = details.nickname)
     loc = HV_WRITE_LIST_JP2_MKDIR(hvs.hvsi,storage.jp2_location)
     filename = HV_FILENAME_CONVENTION(hvs.hvsi,/create)
     jp2_filename = loc + filename
     HV_WRITE_JP2_LWG,jp2_filename,hvs.img,fitsheader = hvs.hvsi.header,details = details,measurement = hvs.hvsi.measurement
     jp2_filename = loc + filename + '.jp2'
     HV_DB,hvs.hvsi,/update
  endif else begin
     print,progname + ': JP2 file was already written, so no new one was written'
  endelse
  return
END
