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
; HV_MDI_PREP2JP2,'~/hv_dat/dat/mdi/2003/','2003/10/01','2003/10/15',/int,/mag
;
;

PRO HV_MDI_PREP2JP2,mdidir,ds,de,int = int, mag = mag,details_file = details_file, copy2outgoing = copy2outgoing,output = output,called_by = called_by
;
; Progname
;
  progname = 'hv_mdi_prep2jp2'
;
; use the default MDI file is no other one is specified
;
  if not(KEYWORD_SET(details_file)) then details_file = 'hvs_default_mdi'
  info = CALL_FUNCTION(details_file)
  nickname = info.nickname
;
; If called_by information is given, pass it along.  Otherwise, just
; use this program name
;
  if keyword_set(called_by) then begin
     info = add_tag(info,called_by,'called_by')
  endif else begin
     info = add_tag(info,progname,'called_by')
  endelse
;
; Fix the dates if need be
;
  if de eq -1 then begin
     get_utc,de,/ecs,/date_only
     print,progname,': end date reset to ' + de
  endif
  if ds eq -1 then begin
     get_utc,ds,/ecs,/date_only
     print,progname,': start date reset to ' + ds
  endif
  if anytim2tai(ds) gt anytim2tai(de) then begin
     print,progname,': start time before end time.  Stopping'
     stop
  endif
;
; Storage locations
;
  storage = HV_STORAGE(nickname = nickname)
;
  if keyword_set(int) then begin
     t0 = systime(1)  
     search_term = '*Ic*.00*.fits'
     output = HV_MDI_PREP2JP2_EACH(mdidir,search_term,ds,de,storage,/int, info = info)
     prepped = output.hv_count
     HV_REPORT_WRITE_TIME,progname,t0,n_elements(prepped)-1
     if keyword_set(copy2outgoing) then begin
        HV_COPY2OUTGOING,prepped
     endif
  endif
  if keyword_set(mag) then begin
     t0 = systime(1)  
     search_term = '*M*.00*.fits'
     output = HV_MDI_PREP2JP2_EACH(mdidir,search_term,ds,de,storage,/mag, info = info)
     prepped = output.hv_count
     HV_REPORT_WRITE_TIME,progname,t0,n_elements(prepped)-1
     if keyword_set(copy2outgoing) then begin
        HV_COPY2OUTGOING,prepped
     endif
  endif

  return
end
