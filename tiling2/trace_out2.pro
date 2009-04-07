
; 11th january 2008
;
; trace_out.pro
;
; Tile TRACE files
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
; TRACE zoom levels calculated on a file by file basis
;
; max spatial resolution (most zoomed in)  Z = 2 + 10
; next zoom level                          Z = 3 + 10
; next zoom level                          Z = 4 + 10
; last zoom level                          Z = 5 + 10
;
; Tile normal LASCO C2 files
;
;
progname = 'trace_out2'

;
; where the images actually are
;
source_images = '/Users/ireland/hv/img/trace/2003_10/'
;
; where the list of images is kept - the list is the contents
; of the directory <source_images>
;
source_list = '/Users/ireland/hv/lists/trace/2003_10_05_trace.txt'

;
; where the images actually are
;
source_images = '/Users/ireland/hv/img/trace/2003/10/05/'
;



;
; nature of the images
;
mission = 'trac'
instrument = 'TRA'
detector = 'TRA'
outdir = ['../../tiles14_trace/','../../jp2_13/']
fitype = 'C'
rewrite = 0

ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'png',/jp2




end
