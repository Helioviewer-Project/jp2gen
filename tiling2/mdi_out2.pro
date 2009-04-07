;
; 11th january 2008
;
; mdi_out.pro
;
; Tile MDI files
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
; MDI zoom levels
;
; max spatial resolution (most zoomed in)  Z = -1 + 10
; next zoom level                          Z = 0 + 10
; next zoom level                          Z = 1 + 10
; last zoom level                          Z = 2 + 10
;
;
;


;
; --- MAGNETIC IMAGES ---
;

progname = 'mdi_out2'


;; where the images actually are

;; source_images = '/Users/ireland/hv/img/mdi/2003/10/mag/'

;; where the list of images is kept - the list is the contents
;; of the directory <source_images>

;; source_list = '/Users/ireland/hv/lists/mdi/2003_10_mdi_mag_sav.txt'

;; source_images = '/Users/ireland/hv/img/mdi/2003/10/mag'
;; source_list = '2003_10_mag.txt'


;; nature of the images

;; mission = 'soho'
;; instrument = 'MDI'
;; detector = 'MDI'
;; outdir = ['../../tiles13/','../../jp2_13/']
;; fitype = 'C'
;; rewrite = 0

;; ji_make_tiles3,source_images,source_list,mission,instrument,detector,outdir,fitype,$
;;                   rewrite = rewrite,format = 'jpg',/jp2


;
; --- INTENSITY IMAGES ---
;

progname = 'mdi_out2'

;
; where the images actually are
;
source_images = '/Users/ireland/hv/img/mdi/2003/10/mag/'
;
; where the list of images is kept - the list is the contents
; of the directory <source_images>
;
source_list = '/Users/ireland/hv/lists/mdi/2003_10_mdi_mag_sav.txt'

mission = 'soho'
instrument = 'MDI'
detector = 'MDI'
outdir = ['../../tiles16/','../../jp2_13/']
fitype = 'C'
rewrite = 0

ji_make_tiles3,source_images,source_list,mission,instrument,detector,outdir,fitype,$
               rewrite = rewrite,format = 'jpg',/jp2

;
; where the images actually are
;
source_images = '/Users/ireland/hv/img/mdi/2003/10/int/'
;
; where the list of images is kept - the list is the contents
; of the directory <source_images>
;
source_list = '/Users/ireland/hv/lists/mdi/2003_10_mdi_int_sav.txt'

mission = 'soho'
instrument = 'MDI'
detector = 'MDI'
outdir = ['../../tiles16/','../../jp2_13/']
fitype = 'C'
rewrite = 0

ji_make_tiles3,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'jpg',/jp2



end
