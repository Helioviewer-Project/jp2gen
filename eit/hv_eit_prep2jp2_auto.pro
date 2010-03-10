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
; USER - set the start date and end date of the range of EIT data you
;        are interested in.  The program will then create JP2 files in
;        the correct directory structure for use with the Helioviewer
;        project.
;
;
PRO HV_EIT_PREP2JP2_AUTO, move2outgoing = move2outgoing
  progname = 'hv_eit_prep2jp2_auto' ; the program name
;
;
;
  repeat begin
;
; Get today's date in UT
;
     get_utc,utc,/ecs,/date_only
     date_start = utc 
     date_end   = utc 
     print,' '
     print,progname + ': Processing... ' + date_start + ' to ' + date_end
;
;
;
     HV_EIT_PREP2JP2,date_start,date_end, move2outgoing = move2outgoing
;
; Wait 15 minutes before looking for more data
;
     print,'Fixed wait time of 15 minutes now progressing.'
     wait,60*15.0

  endrep until 1 eq 0

  return
end

