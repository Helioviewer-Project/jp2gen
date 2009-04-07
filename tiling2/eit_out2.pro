;
; 14th february 2008
;
; eit_out2.pro
;
; Tile EIT files
;
; using more generalized make tile function
;
;
device,decomposed=0
progname = 'eit_out2'

;
; where the images actually are
;
for i = 10,10 do begin
   month =  string(i,format = '(i02)') 
   source_images = '/Users/ireland/hv/img/eit/2003/' + month + '/'
;
; where the list of images is kept - the list is the contents
; of the directory <source_images>
;
   source_list = '/Users/ireland/hv/txt/eit/2003_' + month + '_eit_000.txt'

;
; nature of the images
;
   mission = 'soho'
   instrument = 'EIT'
   detector = 'EIT'
   outdir = ['../../tiles15/','../../jp2_13/']
   fitype = 'C'
   rewrite = 0

   ji_make_tiles3,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'jpg',/jp2

endfor


end
