;
; 23 January 1018
;
; HV_RHESSI_QUICKLOOK_WRITE_IMAGES
;
; Convert RHESSI Quiicklook FITS files to JP2
; 
; Pass a start date and an end date in the form
;
; 2009/11/18
;
; 
;

PRO HV_RHESSI_QUICKLOOK_WRITE_IMAGES,date_start = ds, $ ; date the automated processing starts
                         date_end = de, $   ; date to end automated processing starts
                         details_file = details_file,$                     ; call to an explicit details file
                         copy2outgoing = copy2outgoing,$                   ; copy to the outgoing directory
                         once_only = once_only,$                           ;  if set, the time range is passed through once only
                         overwrite = overwrite,$
                         writtenby = writtenby
;
  progname = 'HV_RHESSI_QUICKLOOK_WRITE_IMAGES'
;
; use the default RHESSI file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then begin
     details_file = 'hvs_rhessi_quicklook'
  endif

;
; Assign the default writtenby choice if no other present
;
  if not(KEYWORD_SET(writtenby)) then begin
     writtenby = 'default'
  endif
;
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname
;
  timestart = systime(0)
  count = long(0)
;
  repeat begin
;
; Get today's date in UT
;
; Number of days back to search.  This should be enough in most
; circumstances.  According to the RHESSI team, the lag for some
; flares can be on the order of weeks.  In addition, the entire
; quicklook archive can, and has been reprocessed.  This means that
; the images available on helioviewer at any given time may not be an
; accurate representation of the current state of the quicklook
; archive.
     ndays = 7
     get_utc,utc,/ecs,/date_only
     utc2date = anytim2cal( anytim2tai(utc)-ndays*24*60*60.0,form=11,/date )
     if (count eq 0) then begin
        if not(keyword_set(ds)) then ds = utc2date
        if not(keyword_set(de)) then de = utc
     endif else begin
        ds = utc2date
        de = utc
     endelse
;
; Get the images
;
     print,' '
     print,progname + ': Processing... ' + ds + ' to ' + de
     hv_rhessi_quicklook_get_images, [ds, de], jp2_filename=jp2_filename, already_written=already_written, $
                  overwrite=overwrite
;
; Copy them to the outgoing directory.
;
     if keyword_set(copy2outgoing) then begin
        HV_COPY2OUTGOING,jp2_filename, delete_original=delete_original
     endif
;
; Wait 15 minutes before looking for more data
;
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,timestart, more = ['examined ' + ds + ' to ' + de],/web
     HV_WAIT,progname,15,/minutes,/web

  endrep until 1 eq keyword_set(once_only)

  return
end
