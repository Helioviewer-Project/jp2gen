;+
; EIT_IMG_TIMERANGE.pro
;
; 2007-10-18: adopted by D. Mueller (DM) from LATEST_EIT_GIF_X (version of
; 2006-07-26) to process all EIT full-disk images between start_date and end_date  
; 2007-10-23 (B. Fleck): apply different scaling (higher contrast), and 
;                fill missing blocks with previous image
;
; 2007-10-23 (DM): implemented a check for regular full-disk images that
; for LZ data

; 2007-10-23  (DM): fixed program number for normal images, included option for 
; cosmic ray removal (cosmicr.pro itself was fixed and included in this file)
;
; 2007-10-26  (DM): added /gif, /jpg , /quality_jpg, and /no_block_fill options
; can now produce jpg's and gif's at the same time
; if /no_block_fill is set, missing blocks are not filled by patches
; of images adjacent in time

;
;2007-11-02 (DM): removed switch for 1996 and 1997
;
;2007-11-26 (DM): fixed bug (exit condition for time loop)
;2007-11-28 (DM):fixed another bug (eit_prep was called twice if >15 blocks were missing)
;2007-12-09 (DM): adjusted scaling
;2008-04-17 (DM): cleaned up header log, fixed ffhr bug, added /progressive keyword to create progressive jpegs
;
;
;-
;______ auxiliary functions definitions______

function eit_file2path, files, exist, exist_count,  $
   collapse=collapse, topeit=topeit, curdirx=curdirx, lz=lz, gavroc=gavroc
;+
;   Name: eit_file2path
;
;   Purpose: translate eit file name to "standard path" on local system
;
;   Input Parameters:
;      files - one or more eit file names (with or without path)
;      
;   Output Parameters:
;      exist       -  boolean vector - <files> online?
;      exist_count -  count where(<files>) online
;
;   Keyword Parameters:
;      topeit   - top level directory (default=EIT_QUICKLOOK)
;      curdir   - if set, set topeit to current directory
;      lz       - if set, set topeit to EIT_LZ and use YYYY/MM format
;      collapse - if set, assme all files in single directory <topeit>
;		  default is GSFC standard topeit/YYYY/MM/DD/filename
;      gavroc   - set if running on gavroche, special directory structure
;                 otherwise will check
;
;   Calling Sequence:
;      eitpath=eit_file2path(eitfilenames [,/collapse, /curdir, topeit='xxx'])
;      eitpath=eit_file2path(filenames,exist,count) 	; exist = online?
;
;   Calling Examples:
;      print,eit_file2path('efr19960521.043112')         ; "GSFC-like" tree
;         ....ate/data/processed/eit/quicklook/1996/05/21/efr19960521.043112
;
;      print,eit_file2path('efr19960521.043112',/collapse)   ; collapsed tree
;         ...ate/data/processed/eit/quicklook/efr19960521

;      print,eit_file2path('efr19960521.043112',/curdir)      ; local version
;         /usr/users/freeland/dev/eitpath/efr19960521.043112
;         
;   History:
;            21-May-1996 (S.L.Freeland) 
;            22-May-1996 (S.L.Freeland) - added 2nd param (exist)
;            01-Aug-1996 (J. Newmark) - added lz keyword for level-zero data
;            16-Aug-1996 (J. Newmark) - added special paths for GAVROC
;            21-Jan-1997 (J. Newmark) - use is_gsfcvms function
;            04-Mar-1997 (J. Nemwark) - allow input of short catalog listing
;            28-Mar-1997 (S. Freeland) - check 'EIT_DATA_STYLE' to allow
;                                        site specification ('collapsed')
;            12-May-1998 (J. Newmark) - allow combination of QKL and LZ
;                                       fix archive location on IS_GSFCVMS
;            22-Jul-1998 (J. Newmark) - fix multiple yr/month in LZ data
;                                       on VMS
;            27-Jan-1998 (J. Newmark) - bug in LZ/QKL combination
;
;
;   Restrictions:
;     assume filenames in given call have same length prefix
;-
if not data_chk(files,/string) then begin
   prstr,["You must supply at least one file name...",$
          "Example: IDL> localfile=eit_file2path(file [,exist, exist_count])"]
   return,''
endif

;
; allow parsing of string output from eit_catrd
zfiles = strlowcase(files)
nfiles = n_elements(zfiles)
ftc = strmid(zfiles(0),0,3)

lz = where(strpos(zfiles,'efz') ne -1,lcnt)
if lcnt eq 1 then lz = lz(0)
ql = where(strpos(zfiles,'efr') ne -1,qcnt)
if qcnt eq 1 then ql = ql(0)

if ftc eq '199' or ftc eq '200' then begin
      if lcnt gt 0 then zfiles(lz) = strmids(zfiles(lz), strpos(zfiles(lz),$ 
                                      'efz'), 18)
      if qcnt gt 0 then zfiles(ql) = strmids(zfiles(ql), strpos(zfiles(ql),$
                                      'efr'), 18)
endif

if lcnt + qcnt eq 0 then begin
         lz = 1
         odate=anytim2utc(/external,strmids(zfiles,0,20))
         for i = 0, nfiles-1 do begin
            tname = strarr(6)
            for j = 0, 5 do tname(j) = strtrim(odate(i).(j),2)
            short = where(strlen(tname) eq 1)
            if short(0) ne -1 then tname(short) = '0' + tname(short)
            zfiles(i)='efz'
            for j = 0, 2 do zfiles(i) = zfiles(i)+tname(j)
            zfiles(i)=zfiles(i)+'.'
            for j = 3, 5 do zfiles(i) = zfiles(i)+tname(j)
         endfor
endif
;

if nfiles eq 1 then retval='' else retval = strarr(nfiles)

; check if on gavroche, xanado, eitv0, magda
if keyword_set(gavroc) or is_gsfcvms() then begin
     today=anytim2utc(!stime)
     break_file,zfiles,xlog,xpath,xfiles,xext,xvers
     ll=strlen(xfiles(0))				 
     year=strmid(xfiles,ll-8,4) & month=strmid(xfiles,11-4,2) 
     day=strmid(xfiles,11-2,2)

     dum=EXECUTE("stat=trnlog('LZ_DATA',translz,/full)")
     dum=EXECUTE("stat=trnlog('QKL_DATA',transql,/full)")

     endlz='['+year+'.'+month+']' 
     endql='['+year+'.'+month+'.'+day+']'

     date=anytim2utc(year+'/'+month+'/'+day)
     date_diff=today.mjd-date.mjd
     if stat eq 1 then begin
          case 1 of
            is_gsfcvms() eq 3: begin
                   if lcnt gt 0 then retval(lz) = translz(0) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(0) + ':' + endql
                   end
            date_diff(0) le 30: begin
                   if lcnt gt 0 then retval(lz) = translz(0) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(0) + ':'
                   end
            else: begin
                   if lcnt gt 0 then retval(lz) = translz(1) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(1) + ':' + endql
                  end
          endcase 
     endif else retval=getenv('REF_DIR')
     retval=retval+xfiles+xext
     if n_params() gt 1 then begin		; optionally check if online
        exist=file_exist(retval)		; files exist?
        online=where(exist,exist_count)
     endif
  return, retval
endif

collapse=keyword_set(collapse) or keyword_set(curdirx) or $
         strlowcase(get_logenv('EIT_DATA_STYLE')) eq 'collapsed'

break_file,zfiles,xlog,xpath,xfiles,xext,xvers	; remove existing path, if any
ll=strlen(xfiles(0))				; 

toplz=get_logenv('EIT_LZ') 
topql=get_logenv('EIT_QUICKLOOK')	

year=strmid(xfiles,ll-8,4) & month=strmid(xfiles,11-4,2) & day=strmid(xfiles,11-2,2)

; D.M. deleted
;; JSN, 1999-11-22 add new code for temporary archive switch
;toplz1=get_logenv('EIT_LZ1') 
;if toplz1 ne '' then begin
;  if strpos(toplz1,'/service/soho-arch03/home') eq -1 then $
;     if year(0) eq '1996' or year(0) eq '1997' then toplz = toplz1
;endif
;

if collapse then begin
  if keyword_set(curdirx) then retval = concat_dir(curdir(),xfiles+xext) else begin	
    if lcnt gt 0 then retval(lz) = concat_dir(toplz,xfiles+xext) 
    if qcnt gt 0 then retval(ql) = concat_dir(topql,xfiles+xext) 
  endelse
endif else begin
  if lcnt gt 0 then retval(lz) = concat_dir(toplz,concat_dir(year,$
       concat_dir(month,xfiles(lz)+xext)))
  if qcnt gt 0 then retval(ql) = concat_dir(topql,concat_dir(year(ql),$
       concat_dir(month(ql), concat_dir(day(ql),xfiles(ql)+xext(ql)))))
endelse

; case convert (convert to local convention)
retval=call_function((['strlowcase','strupcase'])(!version.os eq 'vms'),retval)

if n_params() gt 1 then begin		; optionally check if online
   exist=file_exist(retval)		; files exist?
   online=where(exist,exist_count)
endif

return,retval
end




;+
; NAME:			TODAY
; PURPOSE:		Easy to remember date function.
; CATEGORY:			Utility
; CALLING SEQUENCE:		string_var=today()
;
;		example:	print,today()
;
; INPUTS:			none
; OPTIONAL INPUT PARAMETERS:	none
; KEYWORD PARAMETERS:		none
; OUTPUTS:			string containing today's date
; OPTIONAL OUTPUT PARAMETERS:	none
; COMMON BLOCKS:		none
; SIDE EFFECTS:			I/O performed
; RESTRICTIONS:			none
; PROCEDURE:			get time with IDL systime function;
;				return string in format dd-mon-yr
; MODIFICATION HISTORY:	Written 14-Nov-1994  M. Bruner; Original name: Chkdate
;			21-Nov-1994 - renamed, added header  M.B.
;			
;-
FUNCTION TODAY
;
t=systime(0)
day=strmid(t,8,2)
month=strmid(t,4,3)
year=strmid(t,22,2)
s='-'
return,day+s+month+s+year
end


;===============================================================================
FUNCTION COSMICR, imain,ch
;----------------------------------------------------------------------------
; Cosmic ray correction by thresholding, using spatial median filter
; limit = detection threshold in sigmas
; F. Clette, January 1998
;
; if all elements of array<=0, return the unchanged array (crashed so far)
; 2007-10-24, D. Mueller
;----------------------------------------------------------------------------

nsigmas=3.5 ; threshold for cosmic ray detection
sbin   =7   ; Kernel size for median filter
minthr =0.6 ; Minimum relative detection threshold

; for the brightest parts of the images this last threshold will be the highest
; one.
; at low intensities, the threshold derived from photon statistics takes over.

s=size(imain)

valid=WHERE(imain GT 0,cnt)
IF (cnt GT 0L) THEN BEGIN
  s=size(imain)
  imalim=INTARR(s(1),s(2))
  imamed=FLTARR(s(1),s(2))
  
  t1=systime(1)
  imamed(valid)=MEDIAN(imain(valid),sbin)   ; median used as reference 
                                            ; background
;  PRINT,'Elapsed : ',systime(1)-t1,' sec'

  eitdark=EIT_DARK()

  imamed(valid)=imamed(valid)-eitdark
    
  t1=systime(1)
  imalim(valid)=imamed(valid)+eitdark+$
         ( fix(nsigmas*SQRT( 2.7 + 0.2*imamed(valid) ))>       $
           fix(imamed(valid)*minthr) )
;  PRINT,'Elapsed : ',systime(1)-t1,' sec'

  hit=WHERE(imain GT imalim,ch)
  imacorr=imain
  IF (ch GT 0) THEN begin

    imacorr(hit)=imamed(hit)+eitdark
  ENDIF
  RETURN, imacorr

ENDIF ELSE BEGIN
   ch=0L
   RETURN, imain
   print,'Array has no positive entries - returning.'
ENDELSE

END
;===============================================================================




;________end of auxiliary functions definitions_____

;+
;PRO eit_img_timerange,dir_im=dir_im,start_date=start_date,end_date=end_date,help=help,cosmic=cosmic,gif=gif,jpg=jpg,quality_jpg=quality_jpg,no_block_fill=no_block_fill
;-
PRO eit_img_timerange_1,dir_im=dir_im,start_date=start_date,end_date=end_date,help=help,cosmic=cosmic,gif=gif,jpg=jpg,quality_jpg=quality_jpg,no_block_fill=no_block_fill,progressive=progressive,hv_write = hv_write, hv_count = hv_count, hv_details = hv_details; *** HV ***
hv_count = 0  ; *** HV ***
IF KEYWORD_SET(help) THEN BEGIN
   print,'This is eit_img_timerange.pro.'
   print,'Calling sequence:'
   print,'eit_img_timerange,dir_im=dir_im,start_date=start_date,end_date=end_date,cosmic=cosmic,jpg=jpg,quality_jpg=quality_jpg,no_block_fill=no_block_fill'
   print,'Example:'
   print,"eit_img_timerange,dir='eit_data/',start='2007/01/06',end='2007/01/07',/cosmic,/gif,/jpg"
   return
ENDIF

IF KEYWORD_SET(dir_im) eq 0 THEN BEGIN
   dir_im='./eit_tmp/'
   print,'No directory given, create temporary directory ./eit_tmp/'
ENDIF
spawn,'mkdir '+dir_im

; generate current date:
today_date=today()
today_date_utc=anytim2utc(today_date)

IF KEYWORD_SET(end_date) eq 0 THEN BEGIN
   end_date=today_date
   end_date_utc=anytim2utc(today_date)
   print,'No end date given, assumed end date: today'
ENDIF ELSE BEGIN
   end_date_utc=anytim2utc(end_date)
   IF end_date_utc.mjd gt today_date_utc.mjd THEN $
      print,'chosen end date > today - will stop at date of today.'
ENDELSE

IF KEYWORD_SET(start_date) eq 0 THEN BEGIN
   start_date=today()
   start_date_utc=anytim2utc(start_date)
   start_date_utc.mjd=start_date_utc.mjd-7
   start_date=utc2str(start_date_utc)   
   print,'No start date given, assumed start date '+start_date
ENDIF ELSE BEGIN
   start_date_utc=anytim2utc(start_date)
ENDELSE

; set JPEG quality factor
IF KEYWORD_SET(quality_jpg) eq 0 THEN quality_jpg=75

IF KEYWORD_SET(gif) eq 0 and KEYWORD_SET(jpg) eq 0 and KEYWORD_SET(hv_write) eq 0 THEN BEGIN ; *** HV ***
   gif=1
   print,'No image type set. Creating .gif images.'
ENDIF

;
if not byte(getenv('EIT_BAKEOUT'))  then begin
   set_plot, 'z'
   wave = ['171', '195', '284', '304']
   ;t_val = [1000., 500., 50., 225.]
   ; min_val = [1., 0.50, 0.010, 0.10] & time_line = strarr(4)
; new scaling (Bernhard):
   t_val = [1200., 700., 70., 500.]
   min_val = [5., 2., 0.10, 0.5]
   time_line = strarr(4)
;  
   ffhr_min_val = 4*min_val
;
   semi_colon = string(59b)

; loop over time
n_days=end_date_utc.mjd-start_date_utc.mjd+1
iday=start_date_utc
iday.mjd=start_date_utc.mjd
;
; This picks whether the specified end date or today's LOCAL date is
; the last date on which EIT data is looked for. Since UTC is ahead of
; GSFC, there will be a period of 4 hrs where even although data might
; be coming in, the routine will not write anything.
;
;     while iday.mjd le min([end_date_utc.mjd,today_date_utc.mjd]) do begin
;
; The routine has been changed to look for data up to the specified
; end date, which is passed to the routine with the understanding that
; it is a UTC time.  This allows quicklook data with UTC timestamps
; ahead of local time to be analyzed.
;
while iday.mjd le end_date_utc.mjd do begin ;*** HV ***
   iday_str=utc2str(iday)

;loop over wavelengths
; Image must be: {synoptic (PW) or take normal (N)} and {fffr or ffhr}
; and {wave = <whatever>}.
; If none in a given day, search backward until we find one.
; in the "raw" catalogue entries: .program=14 <-> PW, .program=1 <-> N  
; D.M. 2007-10-23
   
   for i_wave = 0, 3 do begin
		s = eit_catrd(wave = fix(wave(i_wave)),iday_str,/lz)
                ; select 1024x1024 or 512x512 images only:
                fhr=(strpos(s,'32,32') gt 0)+(strpos(s,'2x(16,16)') gt 0)
                s_raw = eit_catrd(wave = fix(wave(i_wave)),iday_str,/lz,/raw)
                s_raw_type=size(s_raw,/tname)
                IF s_raw_type ne 'STRING' THEN BEGIN
                   wx = where((s_raw.program eq 14 or s_raw.program eq 9) and fhr gt 0,nwx) ; check for "PW" and "N" tags ; what about "1"?
                   IF nwx gt 0 THEN BEGIN
                      s = s(wx) 
                      n_file = n_elements(s)
                   ENDIF ELSE BEGIN
                      s=''
                      n_file=0
                   ENDELSE
                ENDIF ELSE BEGIN
                   s=''
                   n_file=0
                ENDELSE           
;
                no_files = 0 
		case n_file of
			0:			no_files = 1
			1:			begin
							no_files = (s(0) eq '') or (strpos(s(0), wave(i_wave) + '::') lt 0)
                                                     end
                        else: no_files=0
		endcase

 day_0=iday
;
;	Couldn't find any in a given day's catalog entry? Step forward
;	in time (until end date or current date) 
             
		while no_files and (day_0.mjd lt min([end_date_utc.mjd,today_date_utc.mjd])) do begin
			day_0.mjd = day_0.mjd + 1
			date_0 = anytim2utc(day_0, /ecs, /date)
                        day_0str=utc2str(day_0)
			print, 'EIT_IMG_TIMERANGE: Next Image D-DATE, date_0 = ', date_0, '.'
                        s = eit_catrd(wave = fix(wave(i_wave)),day_0str,/lz)
                        ; select 1024x1024 or 512x512 images only:
                        fhr=(strpos(s,'32,32') gt 0)+(strpos(s,'2x(16,16)') gt 0)
                        s_raw = eit_catrd(wave = fix(wave(i_wave)),day_0str,/lz,/raw)
                        s_raw_type=size(s_raw,/tname)
                        IF s_raw_type ne 'STRING' THEN BEGIN                         
                           wx = where((s_raw.program eq 14 or s_raw.program eq 9) and fhr gt 0,nwx) ; check for "PW" and "N" tags ; what about "1"?
                           IF nwx gt 0 THEN BEGIN
                              s = s(wx) 
                              n_file = n_elements(s)
                           ENDIF ELSE BEGIN
                              s=''
                              n_file=0
                           ENDELSE
                        ENDIF ELSE BEGIN
                           s=''
                           n_file=0
                        ENDELSE                             
;
                        no_files = 0
			case n_file of
				0:			no_files = 1
				1:			begin
								no_files = (s(0) eq '') or (strpos(s(0), wave(i_wave) + '::') lt 0)
							end
                                else: no_files = 0
			endcase
;
                     endwhile
;
		n_file = n_elements(s) & nmb = intarr(n_file)
;
; Reorder so most recent image is first.
		s = strlowcase(s(n_file - 1 - indgen(n_file)))
		ich = strpos(s(0), 'efr') & today = strmid(s(0), ich + 3, 8)
;
; Temporary adjustment for longer 171 A exposure, 2001 March 2 - 8
;
		if strmid(today, 0, 6) eq '200103' then begin
			day_of_month = strmid(today, 6, 2) & day_of_month = fix(day_of_month)
			if (day_of_month ge 2) and (day_of_month le 8) then t_val(0) = 4.0*t_val(0)
			print, '%EIT_IMG_TIMERANGE-I-T_VAL, t_val(0) = ', t_val(0)
		end
;
		day = today & doy = utc2doy(anytim2utc(day, /date, /ecs))
		summary_file = strarr(4) & planning_file = strarr(4)
		summary_gif = strarr(4)
		found = intarr(4) & i_file = 0
		max_color = 255b

; loop over images on given day; make sure there is data at a wavelength before continuing
                if isarray(s) then begin ; *** HV ***
                   if( (n_elements(s) eq 1) and s[0] eq '' ) then begin
                      print,'No valid EIT data at this wavelength.  Returning'
                   endif else begin
                for is=0,n_elements(s)-1 do begin
                   i_file=is                  
;		full_frame = fffr or ffhr
		fffr = strpos(s(i_file), '32,32') gt 0
		ffhr = strpos(s(i_file), '2x(16,16)') gt 0              
                print,'processing image no. '+string(i_file)+' of '+string(n_elements(s))
                   eit_prep, s(i_file), h, a, cosmic=cosmic, n_block = n_block & nmb(i_file) = n_block
                   
; if blocks are missing, replace them by an adjacent image from the same day
; (unless keyword /no_bock_fill is set)
IF KEYWORD_SET(no_block_fill) eq 0 THEN BEGIN 
   if (n_block gt 0) and (n_block le 15) and n_elements(s) ge 2 then begin
      case i_file of
         0: begin
            if ffhr then a=rebin(a,1024,1024)
            ix=where(a lt 0)
            eit_prep, s(i_file+1), h1, a1,cosmic=cosmic
            a1=rebin(a1,1024,1024)
            a(ix)=a1(ix)
            if ffhr then a=rebin(a,512,512)
         end
         
         else: begin
            if ffhr then a=rebin(a,1024,1024)
            ix=where(a lt 0)
            eit_prep, s(i_file-1), h1, a1,cosmic=cosmic
            a1=rebin(a1,1024,1024)
            a(ix)=a1(ix)
            if ffhr then a=rebin(a,512,512)
         end
   
      endcase
   endif
ENDIF

; if too many blocks are missing, pass the missing block flag to
; eit_prep              
		if (n_block gt 15) and (i_file ge 1) then begin
			i_file = i_file - 1
			eit_prep, s(i_file), h, a, cosmic=cosmic, n_block = n_block & nmb(i_file) = n_block
; update size flags of replacement image:
	fffr = strpos(s(i_file), '32,32') gt 0
	ffhr = strpos(s(i_file), '2x(16,16)') gt 0
;
		endif else if (n_block gt 15) and (i_file eq 0) then begin
			min_nmb = min(nmb) & i_file = !c
			eit_prep, s(i_file), h, a, cosmic=cosmic
                     end

; Start working on the planning file names.
;
		lower_case_file = strlowcase(s(i_file))
		ich_0 = strpos(lower_case_file, 'efr')
		short_file_name = strmid(lower_case_file, ich_0, 18)
		date_string = strmid(short_file_name, 3, 8)
		partial_path = strmid(date_string, 0, 4) + '/' + $
			strmid(date_string, 4, 2) + '/' + $
			strmid(date_string, 6, 2)
		time_string = strmid(short_file_name, 12, 4)
		summary_file_stub = 'seit_00' + wave(i_wave) + '_fd_' + date_string + '_' + $
			time_string
		print, '%EIT_IMG_TIMERANGE-D-STUB, summary_file_stub = ', summary_file_stub
;
		date_obs = strmid(anytim2utc(eit_fxpar(h, 'DATE_OBS'), /ecs), 0, 19)
                datetime_string=strmid(date_obs,0,4)+strmid(date_obs,5,2)+strmid(date_obs,8,2)+'_'+strmid(date_obs,11,2)+strmid(date_obs,14,2)
		time_line(i_wave) = wave(i_wave) + ': ' + date_obs
		print, '%EIT_IMG_TIMERANGE-D-DATE_OBS, date_obs = ', date_obs
		wave_line = strtrim(eit_fxpar(h, 'WAVELNTH'), 2)
		nx = fix(strmid(h(3), 26, 4)) & ny = fix(strmid(h(4), 26, 4))
		object = strtrim(strlowcase(EIT_FXPAR(h, 'OBJECT')), 2)
		this_wave = wave_line
		sc_roll = eit_fxpar(h, 'SC_ROLL')
		print, '%EIT_IMG_TIMERANGE-D-ROLL, sc_roll = ', sc_roll
		found_wave = 1
                loadct, 42 + i_wave, file = getenv('coloreit')

; if image is half-res, then resample to 1024x1024
		if ffhr then begin
			a = a > ffhr_min_val(i_wave) & print, minmax(a)
			b0 = bytscl(alog10(a(*, *) < 4*t_val(i_wave)), min = alog10(ffhr_min_val(i_wave)), $
				max = alog10(4*t_val(i_wave)), top = 255b)  
                        b0=rebin(b0,1024,1024)
		endif else begin
			a = a > min_val(i_wave) & print, minmax(a)
			b0 = bytscl(alog10(a(*, *) < t_val(i_wave)), min =  alog10(min_val(i_wave)), $
				max = alog10(t_val(i_wave)), top = 255b)                                         
                endelse

                IF KEYWORD_SET(gif) THEN BEGIN
                   write_gif,dir_im+datetime_string+'_eit'+this_wave+'_1024.gif',b0
                ENDIF 

                IF KEYWORD_SET(jpg) THEN BEGIN
                   im=fltarr(1024,1024,3)
                   tvlct,r,g,b,/get                            
                   im[*,*,0]=r(b0)    
                   im[*,*,1]=g(b0)                          
                   im[*,*,2]=b(b0)                                                                           
                   WRITE_JPEG,dir_im+datetime_string+'_eit'+this_wave+'_1024.jpg', im,true=3,quality=quality_jpg,progressive=progressive
                ENDIF
;
; Write JP2 files for use with the Helioviewer Project.  Requires the
; JP2Gen suite of programs
;
                if KEYWORD_SET(hv_write) then begin ; *** HV ***
                   sep = STRSPLIT(s(i_file),' ',/extract)
                   HV_EIT_IMG_TIMERANGE,h,b0,ffhr,s(i_file),this_wave,hv_details,'NOTGIVEN',sep[n_elements(sep)-1],already_written = already_written
                   hv_count = hv_count + (1-already_written)
                endif

; end loop over images on given day:
             endfor
             endelse ; *** HV ***
                endif ; *** HV ***
; end loop over wavelengths:
             endfor

; end of time loop:
        ; go to day after last image:
        iday.mjd=day_0.mjd+1
     endwhile
;
     end
;
end
