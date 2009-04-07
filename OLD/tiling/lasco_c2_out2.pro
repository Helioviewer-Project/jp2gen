
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
source_images = '../../Morgan_Test/200310jpg'
source_list = 'c2_oct05.list.txt'



mission = 'soho'
instrument = 'LAS'
detector = '0C2'
outdir = '../../tiles8'
fitype = 'C'
rewrite = 1

ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'png'


end
