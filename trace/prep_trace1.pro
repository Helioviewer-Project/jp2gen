;
; prep_trace1.pro
;
; read in TRACE fits files and convert them into
; a format that can be used to create tiled images
;

;
; where the hv-required source images will go
;
outdir = '/Users/ireland/hv/img/trace/'


;
; find the necessary files
;
file = trace_files('00:00:00 01-OCT-2003', '05:59:59 01-OCT-2003')

;
; read the files in
;
read_trace,file,-1,index,data

;
; prep the data
;
trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple


;
; write the data out
;
ji_write_trace,index,data,outdir=outdir,/gif,hvoutdir = outdir

;
;
;
end
