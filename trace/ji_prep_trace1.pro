;
; prep_trace1.pro
;
; read in TRACE fits files and convert them into
; a format that can be used to create tiled images
;
FUNCTION ji_prep_trace1,filename,outdir
filelist = '/Users/ireland/hv/txt/2003_10_trace.txt'

list = ji_read_txt_list(filelist)
n = n_elements(list)

for i = 0,n-1 do begin
   outfile = '/Users/ireland/hv/img/trace/2003/10/'
   done = ji_trace_prep1(list(i),outfile)
endfor

;
;
;
end
