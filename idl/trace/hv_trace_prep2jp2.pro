;
; Writes the Helioviewer JPEG2000 file
; Inputs:
; header - file header as provided through the TRACE index array
; image - a byte scaled image as provided by the 'trace_scale.pro' procedure
;
PRO HV_TRACE_PREP2JP2, header, image, overwrite=overwrite, jp2_filename = jp2_filename, fitsroot=fitsroot

  ; details file
  details = hvs_trace()

  ; Get the measurement
  measurement = header.wave_len

  ; Nice way to get the times out of the date
  ext = anytim2utc(header.date_obs, /ext)

  ; create an identifier name for the image
  if not(keyword_set(fitsroot)) then begin
     fitsroot = ''
  endif
  ident_name = HV_TRACE_CREATE_FILE_IDENTIFIER(fitsroot, measurement, ext)

  ; TRACE header contains the DP_HEADER integer array.  This must be
  ; converted into a single string in order for it to be stored in
  ; the JP2 header.
  if have_tag(header, 'dp_header') then begin
     string_dp_header = strjoin(header.dp_header, ',')
     header = rep_tag_value(header, string_dp_header, 'dp_header')
  endif

  ; HV information structure
  hvsi = {dir: '', $
          fitsname: ident_name, $
          header: header, $
          comment: '', $
          measurement: measurement, $
          yy: string(ext.year, format='(I4.4)'), $
          mm: string(ext.month, format='(I2.2)'), $
          dd: string(ext.day, format='(I2.2)'), $
          hh: string(ext.hour, format='(I2.2)'), $
          mmm: string(ext.minute, format='(I2.2)'), $
          ss: string(ext.second, format='(I2.2)'), $
          milli: string(ext.millisecond, format='(I3.3)'), $
          details: details}

  ; HV structure
  hvs = {img: image, hvsi: hvsi}
;
;  Create the JPEG2000 file.
;
  hv_make_jp2, hvs, jp2_filename=jp2_filename, already_written=already_written, $
               overwrite=overwrite

  return
END
