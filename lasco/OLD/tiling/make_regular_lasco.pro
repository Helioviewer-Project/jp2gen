;
; .r make_hm.pro
;
; make a set C2 C3 files with Huw Morgan's scaling
;

; location of the list of C2 and C3 lists of  files
;
; These currently point to files in the SOHO archive
;
yyyy = '2003'
hvroot =  '/Users/ireland/hv/'


txtroot = hvroot + 'txt/'
imgroot = hvroot + 'img/las/'


for month = 1,12 do begin

   mm =  string(month,format = '(i02)') 
   c2_dir = txtroot + 'las/' + yyyy + '_' + mm + '_01t31_c2_fits_list.txt'
   c3_dir = txtroot + 'las/' + yyyy + '_' + mm + '_01t31_c3_fits_list.txt'

;
; directory where the output gif images will be stored
;
   spawn, ' mkdir ' + imgroot + yyyy
   spawn, ' mkdir ' + imgroot + yyyy + '/' + mm

   outdir = imgroot + yyyy + '/' + mm + '/'

;
; read the files
;
   c3_list = JI_READ_TXT_LIST(c3_dir)
   nc3 = n_elements(c3_list)
   for i = 0,nc3-1 do begin
      output = ji_make_regular_lasco(c3_list(i),outdir = outdir,/sav,/c3)
   endfor

;
; read the files
;
   c2_list = JI_READ_TXT_LIST(c2_dir)
   nc2 = n_elements(c2_list)
   for i = 0,nc2-1 do begin
      output = ji_make_regular_lasco(c2_list(i),outdir = outdir,/sav,/c2)
   endfor

endfor
;
;
;
END
