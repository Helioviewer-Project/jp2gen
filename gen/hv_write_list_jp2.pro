
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
PRO HV_WRITE_LIST_JP2,hvs,dir, loc = loc, filename = filename, outf = outf
;
;
;
  if is_struct(hvs) then begin
     loc = HV_WRITE_LIST_JP2_MKDIR(hvs,dir)
;     loc = HV_WRITE_LIST_JP2_MKDIR(hvs,dir,/original)
     filename = HV_FILENAME_CONVENTION(hvs,/create)
     HV_WRITE_JP2_LWG,loc + filename,hvs.img,fitsheader = hvs.header,details = hvs.details
     outf = loc + filename
  endif else begin
;
; go through the list 
;
     n = n_elements(list)
     for i = 0,n-1 do begin
;
; check to see if the file is ok
;
        if (list(i) ne '-1') THEN BEGIN
;
; load the file
;
           restore, list(i)
;
; create a directory if need be
;
           loc = HV_WRITE_LIST_JP2_MKDIR(hvs,dir)
;           loc = HV_WRITE_LIST_JP2_MKDIR(hvs,dir,/original)
;
; create the filename
;
           filename = hvs.yy + '_' + hvs.mm + '_' + hvs.dd + '_' + $
                      hvs.hh + hvs.mmm + hvs.ss + '_' + $
                      hvs.details.observatory + '_' + $
                      hvs.details.instrument + '_' + $
                      hvs.details.detector + '_' + $
                      hvs.measurement
;
; call the program to write the JP2 file
;
;           ji_write_jp2_kdu,loc + filename,hvs.img,fitsheader = hvs.header
;
; call the program to write the JP2 file
;
           HV_WRITE_JP2_LWG,loc + filename,hvs.img,fitsheader = hvs.header,details = hvs.details

        ENDIF
     ENDFOR
  ENDELSE
END
