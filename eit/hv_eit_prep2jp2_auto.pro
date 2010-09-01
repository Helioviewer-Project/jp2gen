;
; 9 September 2009.
;
; Prep Quicklook EIT images for use with the Helioviewer Project
;
; Gets today's date (UTC) and looks for new EIT files once every 15 minutes.
;
; Steps taken: Load FITS data, prep + calibrate image, write JP2
; file.  No intermediate data written
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
; sudo mount 129.165.40.191:/Volumes/eit /home/ireland/soho/eit
; USER - set the start date and end date of the range of EIT data you
;        are interested in.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
;
PRO HV_EIT_PREP2JP2_AUTO,date_start = date_start, copy2outgoing = copy2outgoing,details_file = details_file
  progname = 'hv_eit_prep2jp2_auto'; the program name
  wait = 15*60.0
;
;
;
  timestart = systime(0)
  count = long(0)
  repeat begin
;
; Get today's date in UT
;
     get_utc,utc,/ecs,/date_only
     if (count eq 0) then begin
        if not(keyword_set(date_start)) then begin 
           date_start = utc
        endif
     endif else begin
        date_start = utc
     endelse
     date_end = utc
     print,' '
     print,progname + ': Processing... ' + date_start + ' to ' + date_end
;
; Prep the data automagically.
;
     HV_EIT_PREP2JP2,date_start,date_end, copy2outgoing = copy2outgoing, called_by = progname,prepped = prepped,report = report,details_file = details_file
;
; Wait 15 minutes before looking for more data
;
     count = count + long(1)
     HV_REPEAT_MESSAGE,progname,count,timestart, $
                       more = ['examined ' + date_start + ' to ' + date_end,report],$
                       /web
     HV_WAIT,progname,15.0,/minutes,/web

  endrep until 1 eq 0

  return
end

