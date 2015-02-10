;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_COR1_BY_DATE
;
; Purpose     :	Process a days's worth of COR1 data for Helioviewer
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Reads in the catalog of COR1 science images for the specified
;               time range, and processes the images one-by-one into JPEG2000
;               files for use by the Helioviewer project.
;
; Syntax      :	HV_COR1_BY_DATE, DATE
;
; Examples    :	HV_COR1_BY_DATE, '2010-12-01'
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
; Outputs     :	The COR1 FITS files are processed into JPEG2000 files, and
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
;               HV_COR1_PREP2JP2
;
; Common      :	None
;
; Restrictions:	Currently, only polarization sequences are processed.  This is
;               appropriate up to the time of writing (22-Dec-2010).
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
pro hv_cor1_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite,copy2outgoing = copy2outgoing,recalculate_crpix = recalculate_crpix, delete_original=delete_original
  on_error, 2
  progname = 'hv_cor1_by_date'
;
; General variables
;
  g = HVS_GEN()
;
; STEREO specific variables
;
  stereo_information = HVS_STEREO()
  stereob_unresponsive_date = stereo_information.stereob_unresponsive_date
;
; Prepped data - default is no prepped data
;
;  prepped = [g.MinusOneString]
;  first
;
;  Check that the date is valid.
;
  if (n_elements(date) eq 0) or (n_elements(date) gt 2) then message, $
     'DATE must have 1 or 2 elements'
  message = ''
  utc = anytim2utc(date, errmsg=message)
  if message ne '' then message, message
;
;  Determine which buffer to process.
;
  if anytim2tai(date[0]) le anytim2tai(stereob_unresponsive_date) then begin
     if keyword_set(only_synoptic) then ssr=1 else ssr=3 ;(3 = both 1 and 2)
  endif else begin
     ssr = 7
  endelse
;
;  Step through the STEREO spacecraft
;
  sc = HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT(date[0])
  for isc=0, n_elements(sc)-1 do begin
;
;  Reload the STEREO SPICE files.  We do this to make sure we have the
;  very latest information that is relevant to the data we are looking
;  at.  This is done once per spacecraft since it may take a long time
;  to run through all the images from one spacecraft.
;
     load_stereo_spice,/reload
     print,progname + ': examining STEREO-'+sc[isc]
;
;  Get the catalog of COR1 polarization sequence files.
;
     print, progname + ': getting the catalog of COR1 polarization sequence files.'
     if anytim2tai(date[0]) le anytim2tai(stereob_unresponsive_date) then begin
        cat = cor1_pbseries(utc, sc[isc], ssr=ssr, /valid, count=count)
     endif else begin
        cat = cor1_totbseries(utc, sc[isc], ssr=ssr, /valid, count=count)
     endelse

;
;  Process the sequences one-by-one.
;
    if count gt 0 then begin
       for ifile = 0,count-1 do begin
          

          cor1Files = cat[*,ifile].filename
          already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(cor1Files)
          nRequired = (size(cor1Files,/dim))[0]


          cor1FilesExist = total( file_exist(cor1Files) ) eq nRequired


          print,systime() + ': '+ progname + ': file '+trim(ifile+1) + ' out of '+trim(count)
          if not(already_written) and cor1FilesExist then begin
             hv_cor1_prep2jp2, cor1Files, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
             if keyword_set(copy2outgoing) then begin
                HV_COPY2OUTGOING,[jp2_filename], delete_original=delete_original
             endif
          endif
          if already_written then begin
             print,systime() + ': '+ progname + ': JP2 file already written; skipping further processing of '+cat[*,ifile].filename
          endif
          if not(already_written) and not(cor1FilesExist) then begin
             print,systime() + ': '+ progname + ': JP2 file not written because source data does not (yet) exist; skipping processing of '+cor1Files
          endif
       endfor
    endif
;
;  Code for processing total-brightness-only images would go here.
;
  endfor
;
end
