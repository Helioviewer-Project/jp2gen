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
;source_images = '../bfdata/eit'
source_images = '../../img/2003/eit'
source_list = '2003_eit_list.txt'
;source_list = '2003_10_05_eit_list.txt'
mission = 'soho'
instrument = 'EIT'
detector = 'EIT'
outdir = '../../tiles8'
fitype = 'C'
rewrite = 0

ji_make_tiles2,source_images,source_list,mission,instrument,detector,outdir,fitype,$
                  rewrite = rewrite,format = 'jpg'



end
