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
                     copy2outgoing = copy2outgoing,recalculate_crpix = recalculate_crpix, delete_original=delete_original
  on_error, 2
;
; General variables
;
  g = HVS_GEN()
  progname = 'hv_cor2_by_date'
;
; Define the directory where we log errors due to not being able to
; find the SECCHI catalog
;
  cantFindCatalogDir = HV_SECCHI_CANTFINDCATALOG()
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
  sc = HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT(date[0])
;
; Which spacecraft are operational?
;
  sc = HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT(date[0])
  for isc=0, n_elements(sc)-1 do begin
;
; what type of operations?
;
     operations = HV_STEREO_DETERMINE_SIDELOBE_USAGE(sc[isc], date[0])
     print,sc[isc] + ' operational mode = ' + operations
;
; Determine which buffer to process.
;
     if (operations eq "sidelobe1") or (operations eq "sidelobe2") then begin
        ssr = 7
     endif else begin
        if keyword_set(only_synoptic) then ssr=1 else ssr=3 ;(3 = both 1 and 2)
     endelse
;
;  Reload the STEREO SPICE files.  We do this to make sure we have the
;  very latest information that is relevant to the data we are looking
;  at.  This is done once per spacecraft since it may take a long time
;  to run through all the images from one spacecraft.
;
     load_stereo_spice,/reload
     print,progname + ': examining STEREO-'+sc[isc]
;
;  Get the catalog of COR2 polarization sequence files.
;
     cat = cor1_pbseries(utc, sc[isc], /cor2, ssr=ssr, /valid, count=count)
;
;  Process the sequences one-by-one.
;
;;<<<<<<< TREE
     ;; if count gt 0 then begin
     ;;    for ifile = 0,count-1 do begin
     ;;       cor2Files = cat[*,ifile].filename
     ;;       already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(cor2Files)
     ;;       nRequired = (size(cor2Files,/dim))[0]
     ;;       cor2FilesExist = total( file_exist(cor2Files) ) eq nRequired
     ;;       print,'***',cor2FilesExist
     ;;       print,file_exist(cor2Files)
     ;;       print,systime() + ': '+ progname + ': file '+trim(ifile+1) + ' out of '+trim(count)
     ;;       if not(already_written) and cor2FilesExist then begin
     ;;          hv_cor2_prep2jp2, cor2Files, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
     ;;          if keyword_set(copy2outgoing) then begin
     ;;             HV_COPY2OUTGOING, [jp2_filename]
     ;;          endif
     ;;       endif
     ;;       if already_written then begin
     ;;          print,systime() + ': '+ progname + ': JP2 file already written; skipping further processing of '+cor2Files
     ;;       endif
     ;;       if not(already_written) and not(file_exist(filename)) then begin
     ;;          print,systime() + ': '+ progname + ': JP2 file not written because source data does not (yet) exist; skipping processing of '+cor2Files
     ;;       endif
     ;;    endfor
     ;; endif
;; =======
;;      if count gt 0 then begin
;;         for ifile = 0,count-1 do begin
;;            cor2Files = cat[*,ifile].filename
;;            already_written = HV_PARSE_SECCHI_NAME_TEST_IN_DB(cor2Files)
;;            nRequired = (size(cor2Files,/dim))[0]
;;            cor2FilesExist = total( file_exist(cor2Files) ) eq nRequired
;;            print, cor2FilesExist, nRequired
;;            print,cor2Files
;;            print,systime() + ': '+ progname + ': file '+trim(ifile+1) + ' out of '+trim(count)
;;            if not(already_written) and cor2FilesExist then begin
;;               print,systime() + ': '+ progname + ': Triple exposure image being written.'
;;               hv_cor2_prep2jp2, cor2Files, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
;;               if keyword_set(copy2outgoing) then begin
;;                  HV_COPY2OUTGOING, [jp2_filename]
;;               endif
;;            endif
;;            if already_written then begin
;;               print,systime() + ': '+ progname + ': JP2 file already written; skipping further processing of '+cor2Files
;;            endif
;;            if not(already_written) and not(file_exist(filename)) then begin
;;               print,systime() + ': '+ progname + ': JP2 file not written because source data does not (yet) exist; skipping processing of '+cor2Files
;;            endif
;;         endfor
;;      endif
;; >>>>>>> MERGE-SOURCE
;
;  Get the catalog of COR2 double exposure files.
;
     nrepeat = 0
     nrepeat_max = 2
     repeat_time_in_seconds = 00.0
     repeat begin
        print,progname + ': looking at double exposure files.'
        cat = scc_read_summary(date=utc, spacecraft=sc[isc], telescope='cor2', $
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
        print,progname + ': did not find any data for date ' + string(date)
        save_filename = ji_txtrep(date,'/','-') + '.' + JI_SYSTIME() + '.sav'
        print,progname + ': saving date to ' + cantFindCatalogDir + '/' + save_filename
        save,filename = cantFindCatalogDir + '/cor2.' + save_filename, date
     endif else begin
                                ;if datatype(cat,1) eq 'Structure' then begin
;
;  Filter out beacon images, and optionally special event images.
;     
        if (operations eq "sidelobe1") or (operations eq "sidelobe2") then begin
           print,operations +' operations'
           teststr = "(cat.dest eq 'SW')"
           testsize = 256
        endif else begin
           if keyword_set(only_synoptic) then $
              teststr = "(cat.dest eq 'SSR1')" else $
                 teststr = "(cat.dest ne 'SW')"
           testsize = 512
        endelse
;
;  Only process double exposure images.
;
        teststr = teststr + " AND (cat.prog eq 'Doub')"
;
;  Image size must be at least 512x512 (or 256x256 for sidelobe operations)
;
        if (operations ne "sidelobe1") and (operations ne "sidelobe2") then begin
           teststr = teststr + " AND (cat.xsize ge testsize)"
        endif
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
                 if not(already_written) and file_exist(filename)  then begin
                    print,systime() + ': '+ progname + ': Double exposure image being written.'
                    hv_cor2_prep2jp2, filename, overwrite=overwrite, jp2_filename = jp2_filename,recalculate_crpix = recalculate_crpix
                    if keyword_set(copy2outgoing) then begin
                       HV_COPY2OUTGOING, [jp2_filename], 'stereo', delete_original=delete_original
                    endif
                 endif
                 if already_written then begin
                    print,systime() + ': '+ progname + ': JP2 file already written; skipping further processing of '+cat[ifile].filename
                 endif
                 if not(already_written) and not(file_exist(filename)) then begin
                    print,systime() + ': '+ progname + ': JP2 file not written because source data does not (yet) exist; skipping processing of '+cat[ifile].filename
                 endif
              endif else begin
                 print,systime() + ': '+ progname + ': filename for this file returned an empty string, skipping processing.'
              endelse
           endfor
        endif
     endelse                      ;CAT is structure
  endfor                        ;isc
;
end
