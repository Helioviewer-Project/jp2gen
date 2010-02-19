;
; parse the entered times in a simple way
;

FUNCTION HV_MDI_GET_LIST,mdidir,search_term,ds,de
;
  list = file_search(mdidir,search_term)
  nlist = n_elements(list)
;
  dummy = rfits(list[0],head=h1)  ; first observation time in list
  sh1 = fitshead2struct(h1)
  if tag_exist(sh1,'date_obs') then begin
     date_start = sh1.date_obs
  endif else begin
     date_start = sh1.t_obs
  endelse
  list_start = anytim2tai(date_start)

  dummy = rfits(list[nlist-1],head=h1) ; final observation time in list
  sh1 = fitshead2struct(h1)
  if tag_exist(sh1,'date_obs') then begin
     date_end = sh1.date_obs
  endif else begin
     date_end = sh1.t_obs
  endelse
  list_end = anytim2tai(date_end)

  rds = anytim2tai(ds) ; requested start time
  rde = anytim2tai(de) ; requested end time

  list0 = -1
  list1 = -1
  if (rds lt list_start) then begin
     print,'Requested start time earlier than any entry in the list.  Using earliest entry'
     list0 = 0
  endif

  if (rds gt list_end) then begin
     print,'Requested start time later than any entry in the list.  Stopping'
     stop
  endif

  if (rde gt list_end) then begin
     print,'Requested end time later than any entry in the list.  Using last entry.'
     list1 = nlist-1
  endif

  if (rde lt list_start) then begin
     print,'Requested end time earlier than any entry in the list.  Stopping'
     stop
  endif

  if (rde lt rds) then begin
     print,'End time earlier than start time.  Stopping'
     stop
  endif

  if (list0 eq -1) then begin
     list0 = HV_FIND_CLOSEST_IN_TIME(list,rds)
     dummy = rfits(list[list0],head=h)
     date_start = (fitshead2struct(h)).date_obs
  endif

  if (list1 eq -1) then begin
     list1 = HV_FIND_CLOSEST_IN_TIME(list,rde)
     dummy = rfits(list[list1],head=h)
     date_end = (fitshead2struct(h)).date_obs
  endif

  list = list[list0:list1]
  return,{list:list,date_start:date_start,date_end:date_end}
end

;
; 18 November 2009
;
; 2009/04/10 - JI, first version with direct FITS to JP2 conversion
;
; Take a list of MDI images, prep them, and turn them
; into a set of jp2 files with XML headers corresponding to
; the original FITS header
;
; -
; The user supplies the directory where the FITS files are located.
; The program gets all the relevant FITS files and writes them out as
; required. 
;
; HV_MDI_PREP2JP2,'~/hv/dat/mdi/2003/','2003/10/01','2003/10/15',/int,mag
;
;

PRO HV_MDI_PREP2JP2,mdidir,ds,de,int = int, mag = mag,details_file = details_file
  progname = 'hv_mdi_prep2jp2'

;
; ===================================================================================================
;
; Setup some defaults - usually there is NO user contribution below here
;
;
; use the default MDI file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_mdi'
;
  details = CALL_FUNCTION(details_file)
  nickname = details.nickname
;
; Storage locations
;
  storage = HV_STORAGE(nickname = nickname)
;
; MDI Intensity
  if keyword_set(int) then begin
     search_term = '*Ic*.00*.fits'
     prefix = 'int.'
;
; Start timing and get file list
;
     t0 = systime(1)  
     a = HV_MDI_GET_LIST(mdidir,search_term, ds,de)
     date_start = a.date_start
     date_end = a.date_end
     list = a.list
     print,'Closest time to requested start date = ' + date_start
     print,'Closest time to requested end date   = ' + date_end
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
;     filename = prefix + HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Create the subdirectory for the log file.
;
;     HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
;
; Write direct to JP2 from FITS
;
     prepped = HV_MDI_WRITE_HVS(list,storage.jp2_location,/int,details= details)        
;
; Report time taken
;
     HV_REPORT_WRITE_TIME,progname,t0,prepped
  endif
;
; ======================================================================================================
;
; MDI Magnetogram
;
  if keyword_set(mag) then begin
     search_term = '*M*.00*.fits'
     prefix = 'mag.'
;
; Start timing and get file list
;
     t0 = systime(1)  
     a = HV_MDI_GET_LIST(mdidir,search_term, ds,de)
     date_start = a.date_start
     date_end = a.date_end
     list = a.list
     print,'Closest time to requested start date = ' + date_start
     print,'Closest time to requested end date   = ' + date_end
;
; The filename for a file which will contain the locations of the
; JP2 log files
;
;     filename = prefix + HV_LOG_FILENAME_CONVENTION(nickname,date_start,date_end)
;
; Create the subdirectory for the log file.
;
;     HV_LOG_CREATE_SUBDIRECTORY,nickname,date = date_start,subdir = subdir
;
; Write direct to JP2 from FITS
;
     prepped = HV_MDI_WRITE_HVS(list,storage.jp2_location,/mag,details= details)
; 
; Save the log file
;
;     HV_LOG_WRITE,subdir,filename,prepped,/verbose
;
; Report time taken
;
     HV_REPORT_WRITE_TIME,progname,t0,prepped
  ENDIF
;
;
;
end
