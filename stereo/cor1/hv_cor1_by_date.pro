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
;
; Contact     :	WTHOMPSON
;-
;
pro hv_cor1_by_date, date, only_synoptic=only_synoptic, overwrite=overwrite
on_error, 2
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
if keyword_set(only_synoptic) then ssr=1 else ssr=3     ;(3 = both 1 and 2)
;
;  Step through the STEREO spacecraft
;
sc = ['ahead', 'behind']
for isc=0,1 do begin
;
;  Get the catalog of COR1 polarization sequence files.
;
    cat = cor1_pbseries(utc, sc[isc], ssr=ssr, /valid, count=count)
;
;  Process the sequences one-by-one.
;
    if count gt 0 then for ifile = 0,count-1 do $
      hv_cor1_prep2jp2, cat[*,ifile].filename, overwrite=overwrite
;
;  Code for processing total-brightness-only images would go here.
;
endfor
;
end
