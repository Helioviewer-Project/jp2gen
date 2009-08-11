PRO process_list_bf_gif

; Purpose:
;	Calls MK_IMG and applies requested operations for each item in input 
;	list and saves the result as GIF files.
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

; directory where the output FITS files will be stored
;outdir = '/Users/bfleck/TMP/Lasco/Test/'
  outdir = '/Volumes/BackupHD/bfleck/Data/LASCO/GIFs'

  lasco_dir = '/Users/bfleck/Desktop/lasco_2000b.txt'

  listfile=JI_READ_TXT_LIST(lasco_dir)

  sz=size(listfile)
  
  window,0,xs=1024,ys=1024

  IF sz(0) EQ 0 THEN list1 = readlist(listfile,n1) ELSE BEGIN
     list1=listfile
     n1=sz(1)
  ENDELSE

;w256
  init1=1
;boxref=double(35.5)
;box=[582,838,758,965]
;box=[5,1019,5,1019]
  norm = 0
  boxref = 0
  bytes = 1 
  integers =0
  lee = 0
  do_crem = 0                    ; Applies to MK_IMG only
  mask = 1
  fixg = 2
  rat = 1
  distort = 1
  times= 0

  junk = lasco_readfits(list1(0),h,/no_img)

  use_roi='n'
  initval=0
  startind = 0

  IF not(keyword_set(DIR)) THEN dir = './'
  length=strlen(dir)
  IF strmid(dir,length-1,1) NE '/' THEN dir = dir+'/'

;prfx = strlowcase(h.detector)+month

  print,'Processing',n1-startind+1,' files...'

  FOR i=startind,n1-1 DO BEGIN
     print,i,' of ',n1-1
     print,'Reading ',list1[i]
     im = lasco_readfits(list1[i],h,NO_IMG=no_img)
     IF h.naxis1 eq 1024 and h.naxis2 eq 1024 then begin
        IF h.detector EQ 'C3' THEN BEGIN
           print,'using camera C3'
           model=2		; 1=any_year, 2=local year
           hide=1
           minim = 0.95
           maxim = 1.25
	  ;box=[260,780,900,1020]
	  ;box=[540,780,40,1000]
           cam='c3'
        ENDIF ELSE BEGIN
           print,'using camera C2'
           model=2
           hide=0
           minim=0.90
           maxim=2.
           cam='c2'
        ENDELSE
        
        IF (h.detector eq 'C2' and h.filter eq 'Orange' and h.polar eq 'Clear') $
           or (h.detector eq 'C3' and h.filter eq 'Clear' and h.polar eq 'Clear') $
        then begin
           IF do_crem and i GE startind THEN $
              imc = remove_cr(dprev,dhprev,im,h,use_roi,init=initval) $
           ELSE 	imc = im
;print,'Pausing...'
;wait,2
           dprev = im
           dhprev = h
           help,boxref
           im = mk_img(list1[i],minim,maxim,hstr,ratio=rat,fixgaps=fixg,use_model=model, $
                       dO_BYTSCL=bytes,distort=distort, ref_box=boxref, box=box, norm=norm, $
                       lee_filt=lee, hide_pylon=hide,crem=0, MASK_OCC=mask, /LIST, $
                       EXPFAC=efac, times=times) 
           
                                ;stop
           
           im=byte(im)
           maxmin,im
           if cam eq 'c2' then loadct,3
           if cam eq 'c3' then loadct,1
           
           tv,im
           tvlct,r,g,b,/get
           
           fname = utc2yymmdd(str2utc(h.date_obs+'t'+h.time_obs),/hhmmss,/yy)+'_'+cam+'.fts' 
           
           outdirgifs=outdir+'/'+strmid(fname,0,4)+'/'+strmid(fname,4,2)+'/'	
           gifname = utc2yymmdd(str2utc(h.date_obs+'t'+h.time_obs),/hhmmss,/yy)+'_'+cam+'.gif'
           print,'Saving ',outdirgifs+gifname
           write_gif,outdirgifs+gifname,im
        endif
     ENDIF
  ENDFOR
  
  
END
