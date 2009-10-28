;
;
;
function ji_make_regular_lasco,filename,outdir = outdir,sav = sav,c3 = c3, c2 = c2,gif = gif
;
; read in the image
;
  cimg = lasco_readfits(filename,hdr)
  if ( (size(cimg,/dim))(0) eq 1024) then begin
;
; create a date and time
;
     date_obs = hdr.date_obs
     time_obs = hdr.time_obs
     d = strsplit(date_obs,'/',/extract)
     date = d(0) + d(1) + d(2)
     t = strsplit(strmid(time_obs,0,5),':',/extract)
     time = t(0) + t(1)
;
; make the image
;
     if keyword_set(c2) then begin
        cimg = ji_hv_make_image_c2(cimg,hdr,/nologo,/nolabel)
        filename = date + '_' + time + '_LASCO_C2_regular'
     endif

     if keyword_set(c3) then begin
        cimg = ji_hv_make_image_c3(cimg,hdr,/nologo,/nolabel)
        filename = date + '_' + time + '_LASCO_C3_regular'
     endif
;
; dump it out
;
     if ( (size(cimg,/dim))(0) eq 1024) then begin
        cimg = bytscl(cimg)
;     s=size(cimg)
;     window,/free,xsize=s[1],ysize=s[2],/pixmap
        loadct,3
;     erase
;     tvscl,cimg
        if keyword_set(sav) then begin  
;        window,/free,xsize=s[1],ysize=s[2],/pixmap
;        loadct,3
;        erase
;        tvscl,cimg
           tvlct,r,g,b,/get
           hvs = {img:cimg, red:r, green:g, blue:b}
           save,filename = outdir + filename + '.sav', hvs
        endif

        if keyword_set(gif) then begin
           window,/free,xsize=s[1],ysize=s[2],/pixmap
           loadct,3
           erase
           tvscl,cimg
           tvlct,r,g,b,/get
           write_gif,outdir + filename + '.gif',tvrd(),r,g,b
        endif
     endif
  endif
;
;
;
  return, 1
end
