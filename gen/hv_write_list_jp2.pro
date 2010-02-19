
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
PRO HV_WRITE_LIST_JP2,hvs,jp2_filename = jp2_filename
;
; Do the JP2 file
;
  if is_struct(hvs) then begin
     storage = HV_STORAGE(nickname = hvs.details.nickname)
     loc = HV_WRITE_LIST_JP2_MKDIR(hvs,storage.jp2_location)
     filename = HV_FILENAME_CONVENTION(hvs,/create)
     jp2_filename = loc + filename
     HV_WRITE_JP2_LWG,jp2_filename,hvs.img,fitsheader = hvs.header,details = hvs.details
     jp2_filename = loc + filename + '.jp2'
  endif else begin
     print,'Input hvs variable is not a structure.  Stopping'
     stop
  endelse
  return
END
