;
; 5 June 2009 JI: included error checking if LASCO_READFITS decides
; the input file is not a LASCO FITS file.  Processing is aborted for
; the file
;
FUNCTION hv_las_process_list_bf2,listfile, rootdir, nickname , logfilename, STAIND=staind, AGAIN=again, GIFS=gifs, $
		ALLSTARS=allstars, ROOT=root,details = details
;
; program name
;
  progname = 'HV_LAS_PROCESS_LIST_BF2'
;
; JP2Gen constants
;
  g = HVS_GEN()
;
; set this for proper scaling
;
  gifs=1

  COMMON C3_BLOCK, pylonim, ctr, pylon,pylonima

; Purpose:
;	Calls MK_IMG and applies requested operations for each item in input 
;	list and saves the result as FITS files.
;
; Inputs:
;	listfile	STRING	File containing list of filenames for inner image
;
; Keywords:
;	STAIND=	The index of file list to start with (incl REMOVE_CR)
;	/GIFS	Write GIF files
;	ROOT=	Root name of output files with counter; 
;		default is yyyymmdd_hhmmssc[23].fts
;	
;
; Written 10 April 2009 by JI
;
; Adapted from PROCESS_LIST_BF, a program written by B. Fleck.
;	 
;
; Written 14/01/99 by Nathan Rich, NRL
;
; 5/24/00  Add shdr i/o from mk_img
; 04.01.20, nbr - add ROOT= and default filename
;
; 03/19/09  changed input/output BF
;

; create directory listing of files to be processed:
; find <directory> -type f -print > files.txt  
; e.g.: find /Users/bfleck/Archive/private/data/processed/lasco/level_05/0205*/c2/*.fts -type f -print > lasco_list.txt


  COMMON images, prev,hprev, startind, i, init1
  COMMON STAR_SUMS, allstarims,numims, bkg, n_cr, coords, replaced_all
  COMMON RTMVI_COMMON_IMG, prev2,prev3,prev195,prev171,prev284,prev304,box_avg_prev2,box_avg_prev3,prev3_exptime

  maskdir=GETENV('NRL_LIB')+'/lasco/data/calib/'
  print,'Reading ',maskdir+'c3clearmask2.fts'
  pylonim=readfits(maskdir+'c3clearmask2.fts')
  pylonima = readfits(maskdir+'c3clearmask2a.fts')
  pylon=where(pylonima EQ 3)

; directory where the output FITS files will be stored
;outdir = '/Users/bfleck/TMP/Lasco/Test/'
;  outdir = '/Volumes/BackupHD/bfleck/Data/LASCO/FITS/'
;  outdirgifs='/Volumes/BackupHD/bfleck/Data/LASCO/TMP/'
;  lasco_dir = '/Users/bfleck/Desktop/lasco_list43.txt'

;  listfile=JI_READ_TXT_LIST(lasco_dir)
;  listfile = strarr(1)

;
; get the size of the list
;

  sz=size(listfile)
;
; Use the Z-buffer
;
  set_plot,'z'

;  window,0,xs=1024,ys=1024
;
; Read the file if necessary
;
  IF sz(0) EQ 0 THEN BEGIN
     list1 = readlist(listfile,n1) 
  ENDIF ELSE BEGIN
     list1=listfile
     n1=sz(1)
  ENDELSE
;
; Storage for the processed filenames
;
  outfile = strarr(n1)

;w256
  init1=1
;boxref=double(35.5)
;box=[582,838,758,965]
;box=[5,1019,5,1019]
  norm = 	 0
  boxref=	 0
  bytes=	 0
  IF keyword_set(GIFS) THEN bytes=1 
  integers=0
  lee=	 0
  do_crem= 0                    ; Applies to MK_IMG only
  mask=	 1
  fixg=	 2
  rat=	 1
  distort= 1
  times=	 0
;setfont
  IF datatype(allstarims) NE 'UND' THEN replaced_all = lonarr(12000,n1-1)
  IF do_crem THEN no_img=0 ELSE no_img=1
  IF keyword_set(ROOT) THEN prfx=root
;
; make sure the entire list of files contains 1024 x 1024 images ONLY
;
  good = [-1]
  for i = 0,n_elements(list1)-1 do begin
     junk = size(lasco_readfits(list1[i],h))
     if (junk[1] eq 1024) and (junk[2] eq 1024) then begin
        good = [good,i]
     endif
  endfor
  if (n_elements(good) eq 1) then begin
     print,progname + ': LASCO_READFITS there are no 1024 x 1024 pixel files in the given list.  JP2 Processing aborted'
     outfile = g.MinusOneString
  endif else begin
     good = good[1:*]
     list1 = list1[good]
     junk = lasco_readfits(list1[0],h)
;
; junk will return an array if we get an image.
;
;     junk_sz = size(junk)
;     if ( (isarray(junk)) and (junk_sz[0] eq 2)) then begin
;        if ( (junk_sz[1] eq 1024) and (junk_sz[2] eq 1024) ) then begin

     IF h.detector EQ 'C3' THEN BEGIN
        print,'using camera C3'
        model=2                 ; 1=any_year, 2=local year
        hide=1
        minim = 0.99 ; BF values
        maxim = 1.30 ; BF values
        minim = details.minim
        maxim = details.maxim
                                ;box=[260,780,900,1020]
                                ;box=[540,780,40,1000]
        cam='c3'
     ENDIF ELSE BEGIN
        print,'using camera C2'
        model=2
        hide=0
        minim=0.95 ; BF values
        maxim=2.00 ; BF values
        minim = details.minim
        maxim = details.maxim

        cam='c2'
     ENDELSE

     IF keyword_set(AGAIN) THEN use_roi='y' ELSE use_roi='n'
     initval=0
;     IF keyword_set(STAIND) THEN startind = staind ELSE startind = 0
;
; All the filenames are of the required type, so the starting index is
; zero and the number of good files is the same as the number of
; elements in good
;
     startind = 0
     n1 = n_elements(good)

     IF not(keyword_set(DIR)) THEN dir = './'
     length=strlen(dir)
     IF strmid(dir,length-1,1) NE '/' THEN dir = dir+'/'
;prfx = strlowcase(h.detector)+month
     print,'Processing',n1-startind+1,' files...'
     
     FOR i=startind,n1-1 DO BEGIN
        print,i,' of ',n1-1
        print,'Reading ',list1[i]
        im = lasco_readfits(list1[i],h,NO_IMG=no_img)
        this_filename = list1[i]
        IF h.naxis1 eq 1024 and h.naxis2 eq 1024 then begin
           IF do_crem and i GE startind THEN $
              imc = remove_cr(dprev,dhprev,im,h,use_roi,init=initval) $
           ELSE 	imc = im
;
;           maxim = 3*median(imc)
;
;print,'Pausing...'
;wait,2
           dprev = im
           dhprev = h
           help,boxref
           
           IF h.detector NE 'EIT' THEN BEGIN
              set_plot,'x'
;              using_quicklook =  STRPOS(details.called_by,'HV_LASCO_PREP2JP2_QL') ; check to see if we are using the quicklook process
              using_quicklook =  HV_USING_QUICKLOOK_PROCESSING(details.called_by) ; check to see if we are using the quicklook process
              IF using_quicklook THEN BEGIN
                 im2 = lasco_readfits(list1[i],h)
                 IF h.detector EQ 'C2' THEN BEGIN
                    im = HV_MAKE_IMAGE_C2(im2,h,/nologo,/nolabel,fixgaps=2)
;                    prev2 = im
                    if n_elements(size(im,/dim) ne 2) then begin
                       print,progname + ': non-2d image found.'
                    endif
;                    window,0
;                    plot_image,im,title = 'test'
;                    print,min(im),max(im)
;                    read,dummy
                 ENDIF
                 IF h.detector EQ 'C3' THEN BEGIN
                    im = HV_MAKE_IMAGE_C3(im2,h,/nologo,/nolabel,fixgaps=2)
;                    prev3 = im
                 ENDIF
               ENDIF ELSE BEGIN
                 im = mk_img(list1[i],minim,maxim,hstr,ratio=rat,fixgaps=fixg,use_model=model, $
                             dO_BYTSCL=bytes,distort=distort, ref_box=boxref, box=box, norm=norm, $
                             lee_filt=lee, hide_pylon=hide,crem=0, MASK_OCC=mask, /LIST, $
                             EXPFAC=efac, times=times) 
;                 im = mk_img(list1[i],minim,maxim,hstr,ratio=rat,fixgaps=fixg,use_model=model, $
;                             dO_BYTSCL=bytes,distort=distort, ref_box=boxref, box=box, norm=norm, $
;                             lee_filt=lee, hide_pylon=hide,crem=0, MASK_OCC=mask, /LIST, $
;                             EXPFAC=efac, times=times) 
              ENDELSE
                                ;hist1 = 'MK_IMG(/RATIO,USE_MODEL='+trim(string(model))+')'
           ENDIF ELSE BEGIN
              im= float(mk_img(list1(i),minim,maxim,hstr,do_bytscl=bytes, $
                               times=times, /flat_field,/degrid, /automax,/log_scl,/LIST))
                                ;hist1 = 'MK_IMG(/NO_BYTSCL,/FLAT_FIELD,/DEGRID,/LOG_SCL)'
              minim= -1
              maxim= 3
           ENDELSE
                                ;stop
           IF datatype(allstarims) NE 'UND' THEN BEGIN
              IF i EQ startind THEN  help,replaced_all
              IF i GE startind THEN replaced_all[0,i]=coords
           ENDIF
           imc=float(im)
           
;           maxmin,imc
                                ;tvscl,imc
                                ;med = median(imc)
           
                                ;IF i GE startind or i EQ 0 THEN BEGIN
           IF NOT(keyword_set(ROOT)) THEN $
              fname = utc2yymmdd(str2utc(h.date_obs+'t'+h.time_obs),/hhmmss,/yy)+cam+'.fts' ELSE $
                 fname = prfx+'_'+string(format='(I4.4)',i)+'.fts' 
                                ;fname = h.filename
                                ;strput,fname,'4',1
           IF keyword_set(GIFS) THEN BEGIN
                                ;tv,imc
                                ;fname = STRMID(fname,0,8)+'a.gif'
;           gifname = utc2yymmdd(str2utc(h.date_obs+'t'+h.time_obs),/hhmmss,/yy)+cam+'.gif'
;           print,'Saving ',dir+gifname
;           write_gif,gifname,im
           ENDIF 
                                ;get_utc,now,/ecs
                                ;fxaddpar,hstr,'DATE',now,' '
                                ;nhist = n_elements(hist)
                                ;FOR k=0,nhist-1 DO fxaddpar,hstr,'HISTORY',hist(i)
                                ;IF efac LT 0 THEN exphist='No exposure factor correction applied.' ELSE $
                                ;	exphist='Exposure factor correction of '+TRIM(STRING(efac))+' applied.'
                                ;fxaddpar,hstr,'HISTORY',exphist
                                ;   tvscl,imc<maxim>minim
                                ;   REDUCE_STATISTICS,imc,hstr
;        print,'Saving ',dir+fname
;        writefits,outdir+fname,imc,hstr
                                ;ENDIF
        ENDIF
;
; Calculate the LASCO directory
;
        if (strmid(this_filename,0,1) eq path_sep()) then begin
           lascodir = path_sep()
        endif else begin
           lascodir = ''
        endelse
        zzz = strsplit(this_filename,path_sep(),/extract)
        for iii = 0, n_elements(zzz)-2 do begin
           lascodir = lascodir + zzz[iii]+ '/'
        endfor
        
        if (nickname eq 'LASCO-C2') then begin
           outfile(i) = HV_LAS_C2_WRITE_HVS2(lascodir,{cimg:imc,header:h},details = details)
        endif
        if (nickname eq 'LASCO-C3') then begin
           outfile(i) = HV_LAS_C3_WRITE_HVS2(lascodir,{cimg:imc,header:h},details = details)
        endif
        print,i,' this file ',nickname
        
     ENDFOR
     
     IF datatype(allstarims) NE 'UND' THEN allstars=allstarims
     
     return,{hv_count:outfile}
  endelse
END
