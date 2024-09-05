;+
; Name:  hv_rhessi_make_jp2_main
;
; Purpose: Wrapper around hv_rhessi_make_jp2 to make JP2 files of RHESSI images for Helioviewer
;  for flares during time specified.
;
; Calling arguments:
;   timerange - 2-element array of start/end time of images to process (in any anytim format)
;
; Calling example:
;   hv_rhessi_make_jp2_main, ['12-feb-2002','1-mar-2002']
;   
; NOTE: HSI_IMAGEFITS_TOP env var must be set to point to where the RHESSI image cube FITS files are
;
; Written: Kim Tolbert 05-Nov-2020
; Modification History:
;
;
;-
pro hv_rhessi_make_jp2_main, timerange, _extra=_extra

  ;setenv,'HSI_IMAGEFITS_TOP=C:\Users\atolbert\working\hv_test_files\imagecube_fits'   ; on laptop
  setenv,'HSI_IMAGEFITS_TOP=/data/rhessi_extras/imagecube_fits_v2'   ; on hesperia

  checkvar,timerange,anytim('12-feb-2002')

  tr = anytim(timerange)
  
  if n_elements(tr) ne 2 then tr = tr[0] + [0.,86400.]
  if ~valid_time_range(tr) then begin
    message, /info, 'User timerange is invalid: ' + format_intervals(tr,/ut) + '  Aborting.'
    return
  endif

  ; Find the RHESSI image archive FITS files that are in the time range requested, and
  ; call hv_rhessi_make_jp2 for each file to make the jpeg2000 files.
  
  message, /info, 'Making JP2 files for imagecube FITS files that start wihin these times: ' + format_intervals(tr,/ut, /end_date)

  ts = anytim(tr[0], /date_only)
  ; Search a day at a time for all imagecube files in that yyyy/mm/dd/ directory
  while ts lt tr[1] do begin
    te = ts + 86400.d0 < tr[1]
    dir = concat_dir('HSI_IMAGEFITS_TOP', anytim(ts,/ecs,/date_only))
    fitsfiles = file_search(dir, '*.fits', count=nfits)
    if nfits gt 0 then begin
      file_stimes = anytim(file2time(file_basename(fitsfiles)))
      ; Now find the files that are withing user specified start/end times (ts,te) and make jp2 files for them.
      q = where(file_stimes ge tr[0] and file_stimes lt tr[1], nq)
      files = fitsfiles[q]
      for ii = 0,nq-1 do begin
        hv_rhessi_make_jp2, files[ii], _extra=_extra, jp2_files = jp2_files, count = njp2
        print, ' '
        print, 'For input file ' + files[ii] + ',' + trim(njp2) + ' jp2 files written.'
;        if njp2 eq 0 then print, jp2_files
      endfor
    endif else begin
      print, 'No imagecube fits files found for ' + anytim(ts,/ecs,/date_only)
    endelse
    ts = ts + 86400.d0
  endwhile

end
