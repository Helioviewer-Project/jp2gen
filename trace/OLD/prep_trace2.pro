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
; create a list of times to prepare
;
for i = 2,2 do begin
   for j = 3,23 do begin
;
; find the necessary files
;
      day = string(i,format = '(I02)') + '-OCT-2003'
      hr1 = string(j-1,format = '(I02)') + ':00:00'
      hr2 = string(j,format = '(I02)') + ':59:59'

      file = trace_files( hr1 + ' ' + day, hr2 + ' ' + day)

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
      print,'************************************************************'
      print,'images from ' +  hr1 + ' ' + day + '---' + hr2 + ' ' + day
      print,'************************************************************'
      ji_write_trace,index,data,outdir=outdir,/gif,hvoutdir = outdir

   
   endfor
endfor

;
;
;
end
