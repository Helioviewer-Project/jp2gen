;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_COR2_BY_DATE
;
; Purpose     :	Process a days's worth of COR2 data for Helioviewer
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Reads in the catalog of COR2 science images for the specified
;               time range, and processes the images one-by-one into JPEG2000
;               files for use by the Helioviewer project.  Both polarization
;               sequence and double exposure images are processed.
;
; Syntax      :	HV_COR2_BY_DATE, DATE
;
; Examples    :	HV_COR2_BY_DATE, '2010-12-01'
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
; Outputs     :	The COR2 FITS files are processed into JPEG2000 files, and
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
;               HV_COR2_PREP2JP2
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
pro hv_cor2_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite,$
                     copy2outgoing = copy2outgoing,recalculate_crpix = recalculate_crpix
  on_error, 2
;
; General variables
;
  g = HVS_GEN()
;
; Prepped data - default is no prepped data
;
;  prepped = [g.MinusOneString]
  progname = 'hv_cor2_by_date'
;
; First time that a non-zero file is found
;
;  firsttimeflag = 1
;  prepped = -1
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
  if keyword_set(only_synoptic) then ssr=1 else ssr=3 ;(3 = both 1 and 2)
;
;  Step through the STEREO spacecraft
;
  sc = ['ahead', 'behind']
  for isc=0,1 do begin
;
;  Reload the STEREO SPICE files.  We do this to make sure we have the
;  very latest information that is relevant to the data we are looking
;  at.  This is done once per spacecraft since it may take a long time
;  to run through all the images from one spacecraft.
;
     load_stereo_spice,/reload
;
;  Get the catalog of COR2 polarization sequence files.
;
     cat = cor1_pbseries(utc, sc[isc], /cor2, ssr=ssr, /valid, count=count)
;
;  Process the sequences one-by-one.
;
     if count gt 0 then begin
        for ifile = 0,count-1 do begin
           already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(cat[*,ifile].filename)
           if not(already_written) then begin
              hv_cor2_prep2jp2, cat[*,ifile].filename, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
              ;if firsttimeflag then begin
              ;   prepped = [jp2_filename]
              ;   firsttimeflag = 0
              ;endif else begin
              ;   prepped = [prepped,jp2_filename]
              ;endelse
              if keyword_set(copy2outgoing) then begin
                 HV_COPY2OUTGOING, [jp2_filename]
              endif
           endif else begin
              print,systime() + ': '+ progname + ': file already written, skipping processing '+cat[*,ifile].filename
           endelse
        endfor
     endif
;
;  Get the catalog of COR2 double exposure files.
;
     cat = scc_read_summary(date=utc, spacecraft=sc[isc], telescope='cor2', $
                            source='lz', type='img', /check)
     if datatype(cat,1) eq 'Structure' then begin
;
;  Filter out beacon images, and optionally special event images.
;
        if keyword_set(only_synoptic) then $
           teststr = "(cat.dest eq 'SSR1')" else $
              teststr = "(cat.dest ne 'SW')"
;
;  Only process double exposure images.
;
        teststr = teststr + " AND (cat.prog eq 'Doub')"
;
;  Image size must be at least 512x512.
;
        teststr = teststr + " AND (cat.xsize ge 512)"
;
;  Don't process COR2 images with exposure times longer than 20 seconds.  These
;  are "extra" images.
;
        teststr = teststr + " AND (cat.exptime lt 20)"
;
;  Don't process images with exposure times less than 5 seconds after
;  2009-06-01.  These are "extra" images used for generating CME flags.
;
        teststr = teststr + " AND ((cat.date_obs lt '2009-06-01') OR " + $
                  "(cat.exptime ge 5))"
;
;  Process the files one by one.  If the file is not found, then print a
;  message.  This sometimes happens if the catalog file arrives before the FITS
;  file.
;
        dummy = execute("w = where(" + teststr + ", count)")
        if count gt 0 then begin
           cat = cat[w]
           for ifile = 0,count-1 do begin
              filename = sccfindfits(cat[ifile].filename)
              if filename ne '' then begin
                 already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(filename)
                 if not(already_written) then begin
                    hv_cor2_prep2jp2, filename, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
                    ;if firsttimeflag then begin
                    ;   prepped = [jp2_filename]
                    ;   firsttimeflag = 0
                    ;endif else begin
                    ;   prepped = [prepped,jp2_filename]
                    ;endelse
                    if keyword_set(copy2outgoing) then begin
                       HV_COPY2OUTGOING, [jp2_filename]
                    endif
                 endif else begin
                    print,systime() + ': '+ progname +  ': File ' + cat[ifile].filename + ' not (yet) found.'
                 endelse
              endif else begin
                 print,systime() + ': '+ progname + ': file already written, skipping processing '+filename
              endelse
           endfor
        endif
     endif                      ;CAT is structure
  endfor                        ;isc
;
end
