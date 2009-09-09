
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
PRO ji_write_list_jp2,hvs,dir, loc = loc, filename = filename, outf = outf
;
;
;
  if is_struct(hvs) then begin
     loc = JI_WRITE_LIST_JP2_MKDIR(hvs,dir)
     date = hvs.yy + '_' + hvs.mm + '_' + hvs.dd
     time = hvs.hh + '_' + hvs.mmm + '_' +  hvs.ss + '_' + hvs.milli
     observation =  hvs.observatory + '_' + hvs.instrument + '_' + hvs.detector + '_' + hvs.measurement
     filename = date + '__' + time + '__' + observation
;     filename = hvs.yy + '_' + hvs.mm + '_' + hvs.dd + '_' + $
;                hvs.hh + hvs.mmm + hvs.ss + hvs.milli + '_' + $
;                hvs.observatory + '_' + hvs.instrument + '_' + hvs.detector + '_' + hvs.measurement
;     ji_write_jp2_kdu,loc + filename,hvs.img,fitsheader = hvs.header
     ji_write_jp2_lwg,loc + filename,hvs.img,fitsheader = hvs.header
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
           loc = JI_WRITE_LIST_JP2_MKDIR(hvs,dir)
;
; create the filename
;
           filename = hvs.yy + '_' + hvs.mm + '_' + hvs.dd + '_' + $
                      hvs.hh + hvs.mmm + hvs.ss + '_' + $
                      hvs.observatory + '_' + hvs.instrument + '_' + hvs.detector + '_' + hvs.measurement
;
; call the program to write the JP2 file
;
;           ji_write_jp2_kdu,loc + filename,hvs.img,fitsheader = hvs.header
;
; call the program to write the JP2 file
;
           ji_write_jp2_lwg,loc + filename,hvs.img,fitsheader = hvs.header

        ENDIF
     ENDFOR
  ENDELSE
END
