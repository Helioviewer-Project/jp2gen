;
; 16 may 2008
;
; nicked off of this web page
;
; 
;
function JI_EIT_WRITE_hvs,eit_start,eit_end,rootdir
;
;
;
  progname = 'JI_EIT_WRITE_HVS'
;
;  Read in the file and pertinent image header keywords. 
;  *****************************************************

;
; OLD as of 3 April 2009
;outfile = eit_img_timerange_081111(dir=rootdir,start=eit_start,end=eit_end,/hvs,/write_jp2)

outfile = eit_img_timerange_081111(dir_im=rootdir,start=eit_start,end=eit_end,/hvs)

;
; remove the null files
;
return,outfile(where(outfile ne '-1'))
;return,outfile
end
