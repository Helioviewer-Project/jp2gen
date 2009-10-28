;main function
;c2f is c2 filename (including path)
;c3f is c3 filename (including path)
;returns combined c2 and c3 image with:
;nrgf filtering
;point filtering
;fill in missing blocks with radial interpolation
;very slow but pretty robust

function ji_make_c2_c3_image,c2f,c3f,outdir = outdir,timestamp = timestamp,sav = sav,gif = gif

if not(keyword_set(outdir)) then outdir=''

median=9

;define c2 & c3 fields of view
r0=2.2 & c2c3r=6 & r1=15.

; use the full FOV of C3
r1 = 30.

nopolymain=0

;read in c2 file + standard processing
im=lasco_readfits(c2f,hdr,/silent)

; read in the lasco c3
im_c3=lasco_readfits(c3f,hdr_c3,/silent)

; if the input files don't have 1024 px, stop right here

npx_c2 = hdr.naxis1
npx_c3 = hdr_c3.naxis1

if( (npx_c2 eq 1024) and (npx_c3 eq 1024) )then begin

;
; PROCESS THE C2 IMAGE
;
   im = REDUCE_STD_SIZE(im,hdr,/bias,/full)
   bias=offset_bias(hdr)   
   ji_c2_date_obs = hdr.date_obs
   ji_c2_time_obs = hdr.time_obs
   c2_d = strsplit(ji_c2_date_obs,'/',/extract)
   c2_date = c2_d(0) + c2_d(1) +c2_d(2)
   c2_t = strsplit(strmid(ji_c2_time_obs,0,5),':',/extract)
   c2_time = c2_t(0) + c2_t(1)
   c2_filename = c2_date + '_' + c2_time + '_LASCO_C2'
;
; find good and bad pixels
;
   good=where(im+bias ne 0,comp=bad,ncomp=nbad)
;   
; subtract background (monthly minimum)
;
   bg = GETBKGIMG(hdr, mhdr,ffv=1024)
   bg=bg/mhdr.exptime
   im=im/hdr.exptime
   s=size(im)
   sbg=size(bg)
   im=temporary(im)-bg
;  
; set bad pixels to NAN
;
   if nbad gt 0 then im[bad]=!values.f_nan
;
; write the non-processed C2 image
;
;;    print,'Writing NON-PROCESSED C2 image to ' + outdir + c2_filename
;;    jjj = where(im ge 80.0)
;;    if (jjj(0) ne -1) then begin
;;       im(jjj) = 0
;;    endif
;;    ji_imc2 = bytscl(im)
;;    s = size(ji_imc2)
;;    if (keyword_set(timestamp) AND (keyword_set(gif))) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc2
;;       xyouts,0.01,0.01,c2_date + '_' + c2_time,/norm,charsize=2,charthick=1.4,color=255
;;       tvlct,r,g,b,/get
;;       write_gif,outdir + c2_filename + '.regular.timestamp.gif',tvrd(),r,g,b
;;    endif 
;;    if ( NOT(keyword_set(timestamp)) AND keyword_set(gif) ) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc2
;;       tvlct,r,g,b,/get
;;       write_gif,outdir + c2_filename + '.regular.gif',ji_imc2,r,g,b
;;    endif
;;    if keyword_set(sav) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc2
;;       tvlct,r,g,b,/get
;;       hvs = {img:ji_imc2, red:r, green:g, blue:b}
;;       save,filename = outdir +  c2_filename + '.regular.sav', hvs
;;    endif
;;    wdelete
;; stop
; 
; Now do the NRGF 
; make array of heights and position angles for each pixel
;
   sc=get_sun_center(hdr,/star,full=s[1])
   get_ht_pa_2d,s[1],s[2],sc.xcen,sc.ycen,x,y,ht,pa,pix_size=get_sec_pixel(hdr,full=s[1])/get_solar_radius(hdr)
   pix_size=get_sec_pixel(hdr,full=s[1])/get_solar_radius(hdr)
;
; apply NRGF filter to useful FOV
;
   indmn=where(ht gt r0 and ht lt c2c3r and finite(im) eq 1,complement=nindmn)
   im=point_filter_nrgf(im,ht,pa,r0,c2c3r,/return_nrgf)
   im[indmn]=float(hist_equal_huwerror(im[indmn],per=0.1))
   im[nindmn]=0
   imc2=im & pixc2=pix_size & scc2=sc
   sc2=size(imc2) & hdrc2=hdr
;
; PROCESS THE C3 IMAGE
;
   im=lasco_readfits(c3f,hdr,/silent)
   ji_c3_date_obs = hdr.date_obs
   ji_c3_time_obs = hdr.time_obs
   c3_d = strsplit(ji_c3_date_obs,'/',/extract)
   c3_date = c3_d(0) + c3_d(1) +c3_d(2)
   c3_t = strsplit(strmid(ji_c3_time_obs,0,5),':',/extract)
   c3_time = c3_t(0) + c3_t(1)
   c3_filename = c3_date + '_' + c3_time + '_LASCO_C3'
   
   good=where(im ne 0,comp=bad,ncomp=nbad)
   im = REDUCE_STD_SIZE(im,hdr,/bias,/full)
   bg = GETBKGIMG(hdr, mhdr,ffv=1024)
   bg=bg/mhdr.exptime
   im=im/hdr.exptime
   s=size(im)
   sbg=size(bg)
   im=temporary(im)-bg
   ind=where(im lt 0,cntminus)
   
   good2=where(smooth(im,5) lt 360,ngood2,comp=bad2,ncomp=nbad2)
   if nbad2 ne 0 and nbad ne 0 then begin
      bad=[bad,bad2]
      bad=bad[uniq(bad,sort(bad))]
      nbad=n_elements(bad)
   endif
   if nbad eq 0 and nbad2 ne 0 then begin
      bad=bad2
      nbad=nbad2
   endif
   if nbad gt 0 then im[bad]=!values.f_nan
;
; write the non-processed C3 image
;
;;    print,'Writing NON-PROCESSED C3 image to ' + outdir + c3_filename
;;    ji_imc3 = bytscl(im)
;;    s = size(ji_imc3)
;;    if (keyword_set(timestamp) AND (keyword_set(gif))) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc3
;;       xyouts,0.01,0.01,c3_date + '_' + c3_time,/norm,charsize=2,charthick=1.4,color=255
;;       tvlct,r,g,b,/get
;;       write_gif,outdir + c3_filename + '.regular.timestamp.gif',tvrd(),r,g,b
;;    endif 
;;    if ( NOT(keyword_set(timestamp)) AND (keyword_set(gif)) ) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc3
;;       tvlct,r,g,b,/get
;;       write_gif,outdir + c3_filename + '.regular.gif',ji_imc3,r,g,b
;;    endif
;;    if keyword_set(sav) then begin
;;       window,/free,xsize=s[1],ysize=s[2],/pixmap
;;       loadct,3
;;       erase
;;       tvscl,ji_imc3
;;       tvlct,r,g,b,/get
;;       hvs = {img:ji_imc3, red:r, green:g, blue:b}
;;       save,filename = outdir +  c3_filename + '.regular.sav', hvs
;;    endif
;;    wdelete

   
   sc=get_sun_center(hdr,/star,full=s[1])
   im=shift(temporary(im),512-sc.xcen,512-sc.ycen)
   pix_size=get_sec_pixel(hdr,full=s[1])/get_solar_radius(hdr)
   x=(findgen(s[1])-512)*pix_size
   y=(findgen(s[2])-512)*pix_size
   ix=minmax(where_limits(x,-r1,r1))
   iy=minmax(where_limits(y,-r1,r1))
   im=im[ix[0]:ix[1],iy[0]:iy[1]]
   x=x[ix[0]:ix[1]] & y=y[iy[0]:iy[1]]
   s=size(im)
   xx=rebin(x,s[1],s[2]) & yy=rebin(reform(y,1,s[2]),s[1],s[2])
   ht=sqrt(xx^2+yy^2)
   pa=atan(-xx,yy)*!radeg
   ind=where(pa lt 0,cnt)
   if cnt gt 0 then pa[ind]=pa[ind]+360
   
   
   nopolymain=0
   
   indmn=where(ht gt c2c3r and ht lt r1 and finite(im) eq 1,complement=nindmn)
   im=point_filter_nrgf(im,ht,pa,c2c3r,r1,/return_nrgf)
   im[indmn]=float(hist_equal_huwerror(im[indmn],per=0.3))
   im[nindmn]=0
   
   
                                ;since we have clipped C3 image to height r1,
                                ;resize image to 1024x1024
   xra=minmax(x) & yra=minmax(y)
   im=congrid(im,1024,1024,/interp)
   
                                ;recalculate heights
   x=(findgen(1024)*(xra[1]-xra[0])/1023.)+xra[0]
   y=(findgen(1024)*(yra[1]-yra[0])/1023.)+yra[0]
   pix_size=abs(x[1]-x[0])
   s=size(im)
   xx=rebin(x,s[1],s[2]) & yy=rebin(transpose(y),s[1],s[2])
   ht=sqrt(xx^2+yy^2)
   
                                ;roll C3 and C2 images both to north to north, and resize C2 to fit in C3
   roll=get_roll_or_xy(hdr,'ROLL',/DEG)
   rollc2=get_roll_or_xy(hdrc2,'ROLL',/DEG)
   im=rot(im,-roll,1.0,missing=0)
   ji_imc3 = im
   
                                ;
                                ; JI - set the magc2 to be 1.0 so we get full size pixels.
                                ;
   ji_imc2=rot(imc2,-rollc2,1.0,scc2.xcen,scc2.ycen,missing=0)
   magc2=pixc2/pix_size
   imc2=rot(imc2,-rollc2,magc2,scc2.xcen,scc2.ycen,missing=0)
   
                                ;combine c2 and c3
   im=temporary(im)+imc2
                                ;some final equalization on the combined image
   honly = hist_equal(im,per=0.05,/histogram_only)
   im = hist_equal(im,per=0.05)
   
                                ; separate C2 C3 images with the same histogram equalization
                                ; derived from their joint distributions
   ji_imc3 = hist_equal(ji_imc3,per=0.05,fcn = honly)
   ji_imc2 = hist_equal(ji_imc2,per=0.05,fcn = honly)
   
                                ;
                                ; draw sun position in white
                                ;
                                ;indsun=where(ht gt 0.95 and ht le 1.05)
                                ;ji_imc3[indsun]=255
                                ;window,3
                                ;loadct,3
                                ;plot_image,ji_imc3,title = 'Morgan-processed C3'
   
   
                                ; load in the joint image to get the color table

 ;;   im = bytscl(im)
;;    s = size(im)
;;    window,/free,xsize=s[1],ysize=s[2],/pixmap
;;    loadct,3
;;    erase
;;    tvscl,im
;;    xyouts,0.01,0.01,c3_date + '_' + c3_time,/norm,charsize=2,charthick=1.4,color=255
;;    tvlct,r,g,b,/get
;;    wdelete
;;    s = size(ji_imc3)
;;    window,/free,xsize=s[1],ysize=s[2],/pixmap

   print,'Writing PROCESSED C3 image to ' + outdir + c3_filename
   ji_imc3 = bytscl(ji_imc3)
   s=size(ji_imc3)
   if ( keyword_set(timestamp) and keyword_set(gif) ) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc3
      xyouts,0.01,0.01,c3_date + '_' + c3_time,/norm,charsize=2,charthick=1.4,color=255
      tvlct,r,g,b,/get
      write_gif,outdir + c3_filename + '.timestamp.gif',tvrd(),r,g,b
   endif
   if ( NOT(keyword_set(timestamp)) and keyword_set(gif) ) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc3
      tvlct,r,g,b,/get
      write_gif,outdir + c3_filename + '.gif',tvrd(),r,g,b
   endif
   if keyword_set(sav) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc3
      tvlct,r,g,b,/get
      hvs = {img:ji_imc3, red:r, green:g, blue:b}
      save,filename = outdir +  c3_filename + '.sav', hvs
   endif
   wdelete
   
;;    im2=fltarr(1024,1024,3)
;;    ji_imc3 = bytscl(ji_imc3)
;;    tvlct,r,g,b,/get                            
;;    im2[*,*,0]=r(ji_imc3)    
;;    im2[*,*,1]=g(ji_imc3)                          
;;    im2[*,*,2]=b(ji_imc3)                                                                           
;;    WRITE_JPEG,outdir + c3_filename + '.jpg', im2, true=3, quality=100, /progressive
;;    s = size(ji_imc2)
;;    window,/free,xsize=s[1],ysize=s[2],/pixmap
   
   
   

                                ;
                                ;draw sun position in white
                                ;
                                ;indsun=where(ht gt 0.975/magc2 and ht le 1.025/magc2)
                                ;ji_imc2[indsun]=255
                                ;window,2
                                ;loadct,3
                                ;plot_image,ji_imc2,title = 'Morgan-processed C2'
   
                                ;
                                ; construct a file name and save the image
                                ;
;;    c2_d = strsplit(ji_c2_date_obs,'/',/extract)
;;    c2_date = c2_d(0) + c2_d(1) +c2_d(2)
;;    c2_t = strsplit(strmid(ji_c2_time_obs,0,5),':',/extract)
;;    c2_time = c2_t(0) + c2_t(1)
;;    c2_filename = c2_date + '_' + c2_time + '_LASCO_C2'
   
   print,'Writing C2 image to ' + outdir + c2_filename
   ji_imc2 = bytscl(ji_imc2)
   s=size(ji_imc2)
   if (keyword_set(timestamp) AND (keyword_set(gif))) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc2
      xyouts,0.01,0.01,c2_date + '_' + c2_time,/norm,charsize=2,charthick=1.4,color=255
      tvlct,r,g,b,/get
      write_gif,outdir + c2_filename + '.timestamp.gif',tvrd(),r,g,b
   endif 
   if ( NOT(keyword_set(timestamp)) AND (keyword_set(gif)) ) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc2
      tvlct,r,g,b,/get
      write_gif,outdir + c2_filename + '.gif',ji_imc2,r,g,b
   endif
   if keyword_set(sav) then begin
      window,/free,xsize=s[1],ysize=s[2],/pixmap
      loadct,3
      erase
      tvscl,ji_imc2
      tvlct,r,g,b,/get
      hvs = {img:ji_imc2, red:r, green:g, blue:b}
      save,filename = outdir +  c2_filename + '.sav', hvs
   endif
   wdelete
   
   
;;    im2=fltarr(1024,1024,3)
;;    ji_imc2 = bytscl(ji_imc2)
;;    tvlct,r,g,b,/get                            
;;    im2[*,*,0]=r(ji_imc2)    
;;    im2[*,*,1]=g(ji_imc2)                          
;;    im2[*,*,2]=b(ji_imc2)                                                                           
;;    WRITE_JPEG,outdir + c2_filename + '.jpg', im2, true=3, quality=100, /progressive
   
;; 		set color of areas outside useful fov to black
;; 		ind=where(ht ge r1 or ht le r0)
;;                im[ind] = 0
		
;; 		draw sun position in white
;; 		indsun=where(ht gt 0.95 and ht le 1.05)
;; 		im[indsun]=0
;;                 im[indsun]=255
	
;; 		time label
;;  		c2_c3_filename = c2_date + '_' + c2_time + '_' + c3_time +'_LASCO_C2_C3'

;;  		s=size(im)

;; ;; 		invisible window
;;  		window,/free,xsize=s[1],ysize=s[2],/pixmap
		
;; ;; 		set color
;; ;; 		loadct,3

;; ;; 		display image and write time
;;  		erase
;;  		tvscl,im
;;  		xyouts,0.01,0.01,c2_c3_filename,/norm,charsize=1,charthick=1.4,color=255
;; ;;                tvlct,r,g,b,/get
;;  		write_gif, outdir + c2_c3_filename + '.timestamp.gif',tvrd(),r,g,b

;; ;; 		read image from window
;; ;; 		im2=tvrd(true=1,/order)

;; ;; 		this will write GIF image file
;;  		write_gif, outdir + c2_c3_filename + '.gif',im,r,g,b

;;                 print,'Writing joint C2-C3 image to ' + outdir + c2_c3_filename
;; 		delete invisible window
;; 		wdelete

;return combined filtered c2 and c3 image
                return,im

endif else begin
   return,-1
endelse

end
