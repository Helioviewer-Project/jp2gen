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
progname = 'mdi_out2'
source_images = '/Users/ireland/hv/img/2003/mdi/int'
source_list = '2003_10_int.txt'
mission = 'soho'
instrument = 'MDI'
detector = 'MDI'
outdir = '../../tiles6'
fitype = 'C'
rewrite = 0

ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'jpg'


progname = 'mdi_out2'
source_images = '/Users/ireland/hv/img/2003/mdi/mag'
source_list = '2003_10_mag.txt'
mission = 'soho'
instrument = 'MDI'
detector = 'MDI'
outdir = '../../tiles6'
fitype = 'C'
rewrite = 0

ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'jpg'



end
