
; 11th january 2008
;
; eit_out.pro
;
; Tile EIT files
;
;
; writing tile files as
;
; in directory
;
;  YYYY / MM / DD / hh / observatory / instrument / detector / measurement
;
; file name
;
; YYYY _ MM _ DD _ hhmmss _ observatory _ instrument _ detector _ measurement
;
;
; LASCO C2 zoom levels
;
; max spatial resolution (most zoomed in)  Z = 2 + 10
; next zoom level                          Z = 3 + 10
; next zoom level                          Z = 4 + 10
; last zoom level                          Z = 5 + 10
;
; Tile normal LASCO C2 files
;
;
progname = 'lasco_c2_out2'

;source_images = '../bfdata/C2'
;source_list = 'c2_list.txt'
;
;source_images = '../Morgan_Test/200310'
;source_list = 'c2_list.txt'
;
;source_images = '../../Morgan_Test/200310jpg3'
;source_list = 'c2_oct05.list.txt'
;source_list = 'tvrd_c2_oct05.list.txt'

;source_images = '../../Morgan_Test/200310jpg2'
;source_list = 'c2_oct05.list.txt'


;
; where the images actually are
;
for i = 10,10 do begin
   month =  string(i,format = '(i02)') 
   source_images = '/Users/ireland/hv/img/las/2003/' + month + '/'
;
; where the list of images is kept - the list is the contents
; of the directory <source_images>
;
   source_list = '/Users/ireland/hv/txt/las/2003_' + month + '_las_reg_C3.txt'

;
; nature of the images
;
   mission = 'soho'
   instrument = 'LAS'
   detector = '0C3'
   outdir = ['../../tiles15/','../../jp2_14/']
   fitype = 'C'
   rewrite = 0

   ji_make_tiles3,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'png',/jp2

endfor


;; where the images actually are

;; source_images = '/Users/ireland/hv/Morgan_Test/200310jpg2/'

;; where the list of images is kept - the list is the contents
;; of the directory <source_images>

;; source_list = '/Users/ireland/hv/lists/lasco/2003_10_lasco_c2.txt'


;; nature of the images

;; mission = 'soho'
;; instrument = 'LAS'
;; detector = '0C2'
;; outdir = '../../tiles11/'
;; fitype = 'C'
;; rewrite = 0

;; ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
;;                   rewrite = rewrite,format = 'png'


end
