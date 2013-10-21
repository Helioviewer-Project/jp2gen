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

  ; HVS information
  info = HVS_TRACE()
  measurement = info.details[*].measurement
  measurement = ['1700']
  nmeasurement = n_elements(measurement)


  ; read in index from file
  read_trace,filename,-1,index

  ; Split up by measurement
  for j = 0, nmeasurement-1 do begin

     ; filter out the very small images
     ss = where(index.naxis1 gt 128 and index.naxis2 gt 128 and index.wave_len eq measurement[j])

     ; if data survived the filtering process, proceed
     if isarray(ss) then begin
        ; read in the filtered data
        read_trace,filename,ss,ssindex,ssdata

        ; prep the data, and add in the
        ; default processing to generate nice images
        trace_prep,ssindex,ssdata,outindex,outdata,/wave2point,/unspike,/destreak,/deripple

        ; Use the default byte scaling to get nice images
        sdata = trace_scale(outindex, outdata, /byte)
        ; number of images
        nimage = n_elements(outindex)

        ; for each image, call the JPEG2000 writing code
        for i = 0, nimage-1 do begin
           ;print,minmax(sdata[*,*,i])
           ;plot_image, sdata[*,*,i]
           ;read, dummy
           hv_trace_prep2jp2, outindex[i], reform(sdata[*,*,i]), overwrite=overwrite, jp2_filename=jp2_filename, fitsroot=filename
           if keyword_set(copy2outgoing) then begin
              HV_COPY2OUTGOING,[jp2_filename]
           endif
        endfor
     endif
  endfor

  return
END
