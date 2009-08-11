;
; prep_trace1.pro
;
; read in TRACE fits files and convert them into
; a format that can be used to create tiled images
;

;
; where the hv-required source images will go
;
outdir = '/Users/ireland/hv/img/trace/2003/10/27/'

;
; create a list of times to prepare
;

;
; number of days in the month
;

day_start = 27
day_end = 27
nday = 1 + day_end - day_start
;
; number of times to store
;
nhours = nday*24
tr = strarr(nhours,13)

;
; prepare an array of times
;
for i = day_start,day_end do begin
   day = string(i,format = '(I02)') + '-OCT-2003'
   for j = 0,23 do begin
      hr0 = string(j,format = '(I02)') + ':00:00'
      hr1 = string(j,format = '(I02)') + ':05:00'
      hr2 = string(j,format = '(I02)') + ':10:00'
      hr3 = string(j,format = '(I02)') + ':15:00'
      hr4 = string(j,format = '(I02)') + ':20:00'
      hr5 = string(j,format = '(I02)') + ':25:00'
      hr6 = string(j,format = '(I02)') + ':30:00'

      hr7 = string(j,format = '(I02)') + ':35:00'
      hr8 = string(j,format = '(I02)') + ':40:00'
      hr9 = string(j,format = '(I02)') + ':45:00'
      hr10 = string(j,format = '(I02)') + ':50:00'
      hr11 = string(j,format = '(I02)') + ':55:00'
      hr12 = string(j,format = '(I02)') + ':59:59'

      k = (i-day_start)*24 + j

      tr(k,0) =  hr0 + ' ' + day
      tr(k,1) =  hr1 + ' ' + day
      tr(k,2) =  hr2 + ' ' + day
      tr(k,3) =  hr3 + ' ' + day
      tr(k,4) =  hr4 + ' ' + day
      tr(k,5) =  hr5 + ' ' + day
      tr(k,6) =  hr6 + ' ' + day
      tr(k,7) =  hr7 + ' ' + day
      tr(k,8) =  hr8 + ' ' + day
      tr(k,9) =  hr9 + ' ' + day
      tr(k,10) =  hr10 + ' ' + day
      tr(k,11) =  hr11 + ' ' + day
      tr(k,12) =  hr12 + ' ' + day

   endfor
endfor

;
; get the files and prep them
;
for k = 0, nhours-1 do begin
   for i = 0,11 do begin

      print, tr(k,i) + ' -- ' +tr(k,i+1)
      file = trace_files( tr(k,i), tr(k,i+1) )
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
      print,'images from ' + tr(k,i) + '---' + tr(k,i+1)
      print,'************************************************************'
      ji_write_trace,index,data,outdir=outdir,/gif,hvoutdir = outdir
   endfor
endfor

;
;
;
end
