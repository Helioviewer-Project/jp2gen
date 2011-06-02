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
<<<<<<< TREE
pro hv_euvi_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite, prepped = prepped
=======
pro hv_euvi_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite,$
                     copy2outgoing = copy2outgoing
>>>>>>> MERGE-SOURCE
  on_error, 2
<<<<<<< TREE
;
; General variables
;
  g = HVS_GEN()
;
; Prepped data - default is no prepped data
;
  prepped = [g.MinusOneString]
=======
  progname = 'hv_euvi_by_date'
>>>>>>> MERGE-SOURCE
;
;  Check that the date is valid.
;
  if (n_elements(date) eq 0) or (n_elements(date) gt 2) then message, $
     'DATE must have 1 or 2 elements'
  message = ''
  utc = anytim2utc(date, errmsg=message)
  if message ne '' then message, message
;
;  Step through the STEREO spacecraft
;
  sc = ['ahead', 'behind']
<<<<<<< TREE
=======
;
; First time that a non-zero file is found
;
  firsttimeflag = 1
  prepped = -1
;
;
;
>>>>>>> MERGE-SOURCE
  for isc=0,1 do begin
<<<<<<< TREE
=======
;
;  Reload the STEREO SPICE files.  We do this to make sure we have the
;  very latest information that is relevant to the data we are looking
;  at.  This is done once per spacecraft since it may take a long time
;  to run through all the images from one spacecraft.
;
     load_stereo_spice,/reload
>>>>>>> MERGE-SOURCE
;
;  Get the catalog of EUVI image files.
;
     cat = scc_read_summary(date=utc, spacecraft=sc[isc], telescope='euvi', $
<<<<<<< TREE
                           source='lz', type='img', /check)
=======
                            source='lz', type='img', /check)
>>>>>>> MERGE-SOURCE
     if datatype(cat,1) eq 'Structure' then begin
;
;  Filter out beacon images, and optionally special event images.
;
        if keyword_set(only_synoptic) then $
           w = where(cat.dest eq 'SSR1', count) else $
              w = where(cat.dest ne 'SW', count)
;
;  Process the files one by one.  If the file is not found, then print a
;  message.  This sometimes happens if the catalog file arrives before the FITS
;  file.
;
        if count gt 0 then begin
           cat = cat[w]
           for ifile = 0,count-1 do begin
              filename = sccfindfits(cat[ifile].filename)
<<<<<<< TREE
              if filename ne '' then begin
                 hv_euvi_prep2jp2, filename, overwrite=overwrite, jp2_filename = jp2_filename 
=======
              if filename ne '' and file_exist(filename) then begin
                 already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(filename)
                 if not(already_written) and file_exist(filename) then begin
                    hv_euvi_prep2jp2, filename, overwrite=overwrite, jp2_filename = jp2_filename
                    if firsttimeflag then begin
                       prepped = [jp2_filename]
                       firsttimeflag = 0
                    endif else begin
                       prepped = [prepped,jp2_filename]
                    endelse
                    if keyword_set(copy2outgoing) then begin
                       HV_COPY2OUTGOING,[jp2_filename]
                    endif
                 endif else begin
                    print,systime() + ': '+ progname + ': file already written. Skipping processing of '+filename+'.'
                 endelse
>>>>>>> MERGE-SOURCE
              endif else begin
<<<<<<< TREE
                 print, 'File ' + cat[ifile].filename + ' not (yet) found'
                 jp2_filename = g.MinusOneString
=======
                 print,systime() + ': '+ progname +  ': File ' + cat[ifile].filename + ' not (yet) found.'
>>>>>>> MERGE-SOURCE
              endelse
<<<<<<< TREE
              prepped = [prepped,jp2_filename]
=======
>>>>>>> MERGE-SOURCE
           endfor
<<<<<<< TREE
=======
           ;if NOT(firsttimeflag) AND keyword_set(copy2outgoing) then begin
           ;   HV_COPY2OUTGOING,prepped
           ;endif
>>>>>>> MERGE-SOURCE
        endif
     endif
  endfor
;
end
