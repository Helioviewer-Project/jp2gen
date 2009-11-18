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

PRO JI_HV_LASCO_C3_PREP2JP2,ds,de,auto = auto

  date_start = ds + 'T00:00:00'
  date_end = de + 'T23:59:59'

;
; ===================================================================================================
  nickname = 'LASCO-C3'
  progname = 'lasco_c3_prep2jp2_v3'
  list = JI_HV_LASCO_GET_FILENAMES(date_start,date_end,nickname)
;
; Start a clock
;
  t0 = systime(1)
;
; Call details of storage locations
;
  storage = JI_HV_STORAGE(nickname = nickname)
;
; Write direct to JP2 from FITS
;
  prev = fltarr(1024,1024)
  prepped = JI_LAS_WRITE_HVS3(list,storage.jp2_location,nickname,date_start,date_end,/bf_process)
; 
; Save the log file
;
;JI_HV_LOG_WRITE,subdir,filename,prepped,/verbose
;
; Report time taken
;
  JI_HV_REPORT_WRITE_TIME,progname,t0,prepped
  return
end

;; print,' '
;; print,progname
;; print,'--------------------'
;; print,' 1. Select Instrument: C3'
;; print,' 2. Select Filetype and Source: level_05 LZ_IMG'
;; print,' 3. Select Observation Date:'
;; print,' 4. - press "Go" (takes a few seconds)'
;; print,'    a. - in window "LASCO/EIT Image Header Info whdrinfo v.2.1"'
;; print,'    b. - press "Query"'
;; print,'       i. - in pop-up: ROWS: 1024'
;; print,'      ii. - in pop-up: COLS: 1024'
;; print,'     iii. - press "Go"'
;; print,'    c. press "All" - this selects 1024 x 1024 C3 images in the'
;; print,'                     requested time range '
;; print,'    d. - press "Done"'
;; print,' 5. - press "Done"'
;; print,' '
;; print,' The wlister is done, and the program continues'
;; print,' '
;; list = WLISTER()
;
; Create the subdirectory for the log file.
;
;dummy = readfits(list[0],h1)
;JI_HV_LOG_CREATE_SUBDIRECTORY,nickname,date = (fitshead2struct(h1)).obt_time,subdir = subdir
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
;dummy = readfits(list[n_elements(list)-1],h2)
;filename = JI_HV_LOG_FILENAME_CONVENTION(nickname,(fitshead2struct(h1)).obt_time,(fitshead2struct(h2)).obt_time)
;
;
; Instructions on how to use the LASCO software WLISTER for HV
; purposes
;
; 1. Select Instrument: C3
; 2. Select Filetype and Source: level_05 LZ_IMG
; 3. Select Observation Date:
; 4. - press "Go" (takes a few seconds)
;    a. - in window "LASCO/EIT Image Header Info whdrinfo v.2.1"
;    b. - press "Query"
;       i. - in pop-up: ROWS: 1024
;      ii. - in pop-up: COLS: 1024
;     iii. - press "Go"
;    c. press "All" - this selects 1024 x 1024 C3 images in the
;                     requested time range 
;    d. - press "Done"
; 5. - press "Done"
;
; The wlister is done, and the program continues
;
; Setup some defaults - usually there is NO user contribution below here
;

