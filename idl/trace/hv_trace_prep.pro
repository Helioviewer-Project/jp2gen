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
  if isarray(ss) then begin
     ; read in the filtered data
     read_trace,filename,ss,index,data

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

  return
END
