;
; 7 April 09
;
; lasco_c3_prep2jp2_v2.pro
;
; Take a list of LASCO C3 files and
; (1) prep the data
; (2) write out jp2 files
;
;
; USER - use the LASCO software program (in Solarsoft) to determine
;        the time range you are interested in.  The program will then
;        create JP2 files in the correct directory structure for use
;        with the Helioviewer project.

PRO HV_LASCO_C3_PREP2JP2,ds,de,auto = auto,details_file = details_file
  progname = 'hv_lasco_c3_prep2jp2'
;
  date_start = ds + 'T00:00:00'
  date_end = de + 'T23:59:59'
;
; ===================================================================================================
;
; use the default LASCO-C3 file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_lasco_c3'
;
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname
  list = HV_LASCO_GET_FILENAMES(date_start,date_end,nickname,info)
;
; Start a clock
;
  t0 = systime(1)
;
; Call details of storage locations
;
  storage = HV_STORAGE(nickname = nickname)
;
; Write direct to JP2 from FITS
;
  prev = fltarr(1024,1024)
  prepped = HV_LAS_WRITE_HVS3(list,storage.jp2_location,nickname,date_start,date_end,/bf_process,details = info)
;
; Report time taken
;
  HV_REPORT_WRITE_TIME,progname,t0,prepped
  return
end
