;
; October 8 2013
; hv_trace_prep.pro
;
; prepares TRACE data for use with the Helioviewer project.
;
; Cribbed from the TRACE Analysis Guide
;
; http://www.mssl.ucl.ac.uk/surf/guides/tag/tag_top.html
;
;
PRO HV_TRACE_PREP,filename, copy2outgoing=copy2outgoing

  ; read in index from file
  read_trace,filename,-1,index

  ; filter out the very small images
  ss = where(index.naxis1 gt 128 and index.naxis2 gt 128)

  ; if data survived the filtering process, proceed
  if ss ne -1 then begin
     ; read in the filtered data
     read_trace,files,ss,index,data

     ; prep the data, and add in the
     ; default processing to generate nice images
     trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple,/normalize

     ; Use the default byte scaling to get nice images
     sdata = trace_scale(outindex, outdata, /despike, /byte)

     ; number of images
     nimage = n_elements(outindex)

     ; for each image, call the JPEG2000 writing code
     for i = 0, nimage-1 do begin
        hv_trace_prep2jp2, outindex[i], reform(sdata[*,*,i]), overwrite=overwrite, jp2_filename=jp2_filename, fitsroot=filename
        if keyword_set(copy2outgoing) then begin
           HV_COPY2OUTGOING,[jp2_filename]
        endif
     endfor

  endif

;
; Writes the Helioviewer JPEG2000 file
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
  ident_name = HV_TRACE_CREATE_FILE_IDENTIFIER_NAME(fitsroot, measurement, ext)

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

;
; 8 October 2013
; Create a image/file identifier name for each TRACE image
;
FUNCTION HV_CREATE_TRACE_FILE_IDENTIFIER_NAME, fitsroot, measurement, ext
  return, fitsroot + $
          '__' + $
          string(ext.year, format='(I4.4)') + string(ext.month, format='(I2.2)') + string(ext.day, format='(I2.2)') + '_' + $
          string(ext.hour, format='(I2.2)') + string(ext.minute, format='(I2.2)') + string(ext.second, format='(I2.2)') + $
          '__' + $
          measurement
