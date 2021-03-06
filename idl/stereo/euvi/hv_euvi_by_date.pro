;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_EUVI_BY_DATE
;
; Purpose     :	Process a days's worth of EUVI data for Helioviewer
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Reads in the catalog of EUVI science images for the specified
;               time range, and processes the images one-by-one into JPEG2000
;               files for use by the Helioviewer project.
;
; Syntax      :	HV_EUVI_BY_DATE, DATE
;
; Examples    :	HV_EUVI_BY_DATE, '2010-12-01'
;
; Inputs      :	DATE    = Either the date of observation, or a beginning and
;                         end time to search on.  When a single date is passed,
; 			  the entire day is processed.  Otherwise, only the
; 			  portion between the beginning and end times are
; 			  processed.
;
;                         Note that when two dates are passed, they're treated
;                         as times.  If no specific time of day is specified,
;                         then 00:00 is assumed.  For example,
;
;                               DATE=['2007-12-01', '2007-12-03']
;
;                         would process all data from Dec 1 and Dec 2, but
;                         would stop at the beginning of Dec 3.
;
; Opt. Inputs :	None.
;
; Outputs     :	The EUVI FITS files are processed into JPEG2000 files, and
;               associated products.
;
; Opt. Outputs:	None.
;
; Keywords    :	ONLY_SYNOPTIC = If set, then only files from the SECCHI
;                               synoptic buffer are processed.  The default is
;                               to process both the synoptic and special event
;                               buffers.
;
;               OVERWRITE = If set, then write the file even if already present
;
; Calls       :	ANYTIM2UTC, SCC_READ_SUMMARY, DATATYPE, SCCFINDFITS,
;               HV_EUVI_PREP2JP2
;
; Common      :	None
;
; Restrictions:	None.
;
; Side effects:	If a file is not found, then a message is printed, and the
;               program steps to the next file.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 22-Dec-2010, William Thompson, GSFC
;               08-Apr-2011, Jack Ireland, GSFC, added a prepped data
;               return function
;
; Contact     :	WTHOMPSON
;-
;
pro hv_euvi_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite,$
                     copy2outgoing = copy2outgoing,recalculate_crpix = recalculate_crpix, delete_original=delete_original
  on_error, 2
;
; General variables
;
  g = HVS_GEN()
;
; Prepped data - default is no prepped data
;
;  prepped = [g.MinusOneString]
  progname = 'hv_euvi_by_date'
;
;  Check that the date is valid.
;
  if (n_elements(date) eq 0) or (n_elements(date) gt 2) then message, $
     'DATE must have 2 elements'
  message = ''
  utc = anytim2utc(date, errmsg=message)
;
; Define the directory where we log errors due to not being able to
; find the SECCHI catalog
;
  cantFindCatalogDir = HV_SECCHI_CANTFINDCATALOG()
;
; Which spacecraft are operational?
;
  sc = HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT(date[0])

  for isc=0, n_elements(sc)-1 do begin
;
; what type of operations?
;
     operations = HV_STEREO_DETERMINE_SIDELOBE_USAGE(sc[isc], date[0])
;
;  Reload the STEREO SPICE files.  We do this to make sure we have the
;  very latest information that is relevant to the data we are looking
;  at.  This is done once per spacecraft since it may take a long time
;  to run through all the images from one spacecraft.
;
     load_stereo_spice,/reload
     print,progname +': examining STEREO-'+sc[isc]
;
;  Get the catalog of EUVI image files.
;
     nrepeat = 0
     nrepeat_max = 2
     repeat_time_in_seconds = 0.0
     repeat begin
        cat = scc_read_summary(date=utc, spacecraft=sc[isc], telescope='euvi', $
                               source='lz', type='img', /check)
        print, progname + ': catalog datatype: ' + datatype(cat,1)
        if datatype(cat,1) ne 'Structure' then begin
           nrepeat = nrepeat + 1
           print,progname + ': '+ji_systime()
           print,progname + ': completed repeat number '+trim(nrepeat) + ' out of ' + trim(nrepeat_max)
           print,progname + ': total repeat wait time is ' + trim(repeat_time_in_seconds*nrepeat_max/60.0)+' in minutes.'
           HV_WAIT,progname,repeat_time_in_seconds,/seconds
        endif
     endrep until (datatype(cat,1) eq 'Structure') or (nrepeat ge nrepeat_max)
     if (datatype(cat,1) ne 'Structure') then begin
        print,progname + ': '+ji_systime()
        print,progname + ': did not find any data for date ' + ji_txtrep(date,'/','-')
        save_filename = ji_txtrep(date,'/','-') + '.' + JI_SYSTIME() + '.sav'
        print,progname + ': saving date to ' + cantFindCatalogDir + '/' + save_filename
        save,filename = cantFindCatalogDir + '/' + save_filename, date
     endif else begin
     ;if datatype(cat,1) eq 'Structure' then begin
;
; Determine which buffer to process.
;
        if (operations eq "sidelobe1") or (operations eq "sidelobe2") then begin
           if keyword_set(only_synoptic) then $
              w = where(cat.dest eq 'SSR1', count) else $
                 w = where(cat.dest eq 'SW', count)
        endif else begin
           if keyword_set(only_synoptic) then $
              w = where(cat.dest eq 'SSR1', count) else $
                 w = where(cat.dest ne 'SW', count)
        endelse
;
;  Process the files one by one.  If the file is not found, then print a
;  message.  This sometimes happens if the catalog file arrives before the FITS
;  file.
;
        if count gt 0 then begin
           cat = cat[w]
           for ifile = 0,count-1 do begin
              filename = sccfindfits(cat[ifile].filename)
              if filename ne '' and file_exist(filename) then begin
                 print,systime() + ': '+ progname + ': file '+trim(ifile+1) + ' out of '+trim(count)
                 already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(filename)
                 if not(already_written) and file_exist(filename) then begin
                    hv_euvi_prep2jp2, filename, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
                    if keyword_set(copy2outgoing) then begin
                       HV_COPY2OUTGOING,[jp2_filename], 'stereo', delete_original=delete_original
                    endif
                 endif else begin
                    print,systime() + ': '+ progname + ': file already written. Skipping processing of '+filename+'.'
                 endelse
              endif else begin
                 print,systime() + ': '+ progname +  ': File ' + cat[ifile].filename + ' not (yet) found.'
              endelse
           endfor
        endif
     endelse
  endfor
;
end
