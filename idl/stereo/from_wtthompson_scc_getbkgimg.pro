FUNCTION scc_getbkgimg, inhdr, outhdr=outhdr, silent=silent, totalb=totalb, $
                        daily=daily, MATCH=match, interpolate=k_interp, ROLL=roll, $
			NONLINEARITYCORRECTION=nonlinearitycorrection, $
                        calroll=calroll, raw_calroll=raw_calroll, _EXTRA=_extra
;
;+
; $Id: scc_getbkgimg.pro,v 1.67 2011/07/21 21:52:36 nathan Exp $
;
; Project   : STEREO SECCHI
;                   
; Name      : SCC_GETBKGIMG
;               
; Purpose   : Find and read SECCHI background image
;               
; Explanation: This procedure returns the appropriate background image for a
;              given SECCHI fits header
;               
; Use       : IDL> background = scc_getbkgimg(hdr,outhdr=outhdr)
;    
; Inputs    :hdr: secchi fits header (preferably as a structure)
;               
; Outputs   : background model image data and (optionally) header from the background file
;
; Keywords  : /SILENT = Don't print out informational messages
;             /TOTALB = Look for the total brightness background
;             /INTERPOLATE = Interpolate between background images.
;             /DAILY  = Use daily background image instead of monthly.
;             /CALROLL= Use combination of monthly minimum and calibration roll
;                       backgrounds.  These backgrounds may show some problems
;                       during the long gap between calibration rolls in mid to
;                       late 2007
;             /RAW_CALROLL = Use raw calibration roll backgrounds.  This option
;                       is not recommended, and is included mainly to support
;                       generating the combined monthly/calroll backgrounds.
;             OUTHDR  = returns the header of the background image
;   	      /MATCH  = Match state of bias, exptime, summing, size of output to input hdr
;   	      /ROLL = if difference in CROTA is GT 1 deg, rotate bkg to match input
;   	      /NONLINEARITYCORRECTION = apply COR2 double exposure non-lineariy correction (experimental)
;
; Calls from LASCO : 
;
; Common    : None.
;               
; Restrictions: Need 'SECCHI_BKG' environment variable
;               
; Side effects: None.
;               
; Category    : SECCHI, Calibration
;               
; Prev. Hist. : None.
;
; Written     : Karl Battams, NRL/I2, APR 2007
;               
; $Log: scc_getbkgimg.pro,v $
; Revision 1.67  2011/07/21 21:52:36  nathan
; for double images, go to TBr if dbTB not found
;
; Revision 1.66  2011/07/21 20:10:07  secchia
; do not go to TBr if dbl not available
;
; Revision 1.65  2011/07/13 19:32:00  thompson
; Remove restriction on use of 'tbr' with COR1
;
; Revision 1.64  2011-05-09 23:10:34  secchib
; nr - re-commit new straylight pattern date for cor2-b
;
; Revision 1.63  2011/04/29 20:19:43  secchib
; nr - remove new stray light date until we have a new bkg
;
; Revision 1.62  2011/04/27 17:43:27  nathan
; add cor2-b event
;
; Revision 1.61  2011/03/21 17:45:36  thompson
; Added COR1-A event on 2011-03-08, and COR1-B event on 2011-03-11
;
; Revision 1.60  2011/02/28 16:00:41  thompson
; Added COR1-A event on 2011-02-11
;
; Revision 1.59  2011-02-15 21:50:28  nathan
; Handle all changes in background the same way, as dates in array pointing;
; utilize debugon flag for not-silent
;
; Revision 1.58  2011/02/04 20:29:22  nathan
; stray light change special case
;
; Revision 1.57  2011/02/02 16:57:21  secchib
; LM - set factor if bkg the same
;
; Revision 1.56  2011/01/28 16:30:44  thompson
; Added COR1-A event on 2011-01-12
;
; Revision 1.55  2011/01/19 20:57:04  nathan
; treat HI islevelone differently
;
; Revision 1.54  2010/12/02 15:59:18  thompson
; Added COR1-A change on 2010-11-19
;
; Revision 1.53  2010/11/19 14:47:29  mcnutt
; will look for double background if DOUBLE if not found will look for TB backgrounds
;
; Revision 1.52  2010/08/06 20:02:41  nathan
; fixed problem with different size bkg introduced with previous rev
;
; Revision 1.51  2010/05/03 18:46:01  nathan
; Check filename for level-1 and process accordingly; this necessitated moving
; a few things around.
;
; Revision 1.50  2010/04/09 16:27:51  thompson
; Add COR1-B event of 2010-03-24.
;
; Revision 1.49  2010/02/12 23:17:57  thompson
; Added COR1A event of 2010-01-27
;
; Revision 1.48  2009/05/14 16:29:44  thompson
; Treat COR1 change from 1024x1024 to 512x512 as a repoint, except for raw calroll
; data.
;
; Revision 1.47  2009/03/26 16:23:34  nathan
; oops
;
; Revision 1.46  2009/03/26 15:41:00  nathan
; give a notice and exit early if cor1 tbr is requested
;
; Revision 1.45  2009/02/11 20:07:12  thompson
; Add COR1 change on 2009-01-30
;
; Revision 1.44  2008-11-20 14:01:27  mcnutt
; if match checks distcorr and applies cor2_warp if different
;
; Revision 1.43  2008/09/26 19:29:18  nathan
; set ipsum in outhdr
;
; Revision 1.42  2008/09/18 21:50:05  nathan
; Fixed incorrect hdr when /interp; set nmissing=0
;
; Revision 1.41  2008/08/28 16:28:32  nathan
; workaround for incorrect polar val in DOUBLE header (bug 222)
;
; Revision 1.40  2008/08/26 21:28:37  thompson
; Added keywords /calroll and /raw_calroll
;
; Revision 1.39  2008/07/02 19:51:25  nathan
; Updated outhdr CRPIX,CDELT if resizing; use CRPIX for rot if /ROLL (Bug 317)
;
; Revision 1.38  2008/06/17 18:29:44  nathan
; added some info messages
;
; Revision 1.37  2008/05/08 20:56:02  thompson
; Check against dates of major spacecraft repointings.
; Fixed bug extrapolating to recent dates.
;
; Revision 1.36  2008/04/15 21:07:01  nathan
; acknowledge /TOTALB in case polar value is incorrect
;
; Revision 1.35  2008/04/14 19:29:25  nathan
; forgot 1 case for closestisbefore var
;
; Revision 1.34  2008/04/14 14:53:06  nathan
; There were problems with the implementation of finding bracketing background
; images that was introduced in rev 1.19. So I reverted to the previous revision and then
; added the features added up to rev 1.33. I also changed some of the variable
; names for consistency through the different parts of the program.
;
; Revision 1.18  2007/10/26 22:46:16  nathan
; Made some changes for new SECCHI_BKG images: looks for files in
; $SECCHI_BKG/../newbkg (NRL only for beta testing--will be removed
; before SSW update); uses DATE-AVG (if available) instead of DATE-OBS
; for image (midpoint) time
;
; Revision 1.17  2007/10/09 20:35:33  thompson
; Removed 2 second wait
;
; Revision 1.16  2007/10/09 19:28:17  thompson
; Extended /SILENT to no-file-found message.
;
; Revision 1.15  2007/10/05 17:44:48  nathan
; Added /MATCH; outhdr.date_obs=inhdr.date_obs if /INTERP set; correct values
; in outhdr which are not currently set correctly in background image FITS
; headers
;
; Revision 1.14  2007/10/04 19:16:32  thompson
; Improved interpolation file selection.
; Changed CONGRID back to REBIN
;
; Revision 1.13  2007/10/03 21:18:01  thompson
; Added keyword /INTERPOLATE
;
; Revision 1.12  2007/09/27 21:11:30  thompson
; Correct NAXIS1/NAXIS2 in output header
;
; Revision 1.11  2007/09/06 15:08:24  nathan
; added _EXTRA; check for seb_prog=DOUBLE (still needs further tweaking to match TBr background to double image
;
; Revision 1.10  2007/09/05 19:00:13  thompson
; bug fix for /daily keyword
;
; Revision 1.9  2007/08/15 15:57:06  reduce
; Tweaked so it should work for mvi headers. Karl B.
;
; Revision 1.8  2007/07/25 21:00:32  thompson
; Added keyword /DAILY
;
; Revision 1.7  2007/07/25 15:49:42  thompson
; Changed REBIN to CONGRID
;
; Revision 1.6  2007/07/10 19:17:51  thompson
; Fixed small typo
;
; Revision 1.5  2007/07/09 20:31:33  thompson
; Rewrote to search by modified julian date
;
; Revision 1.4  2007/07/05 20:13:45  thompson
; Bug fixes.  Don't use CD.  Call function REDUCE.
;
; Revision 1.3  2007/07/05 19:02:53  reduce
; Took out wait command. Fixed bug with finding 0-deg files
;
; Revision 1.2  2007/07/03 20:27:33  colaninn
; added silent keyword
;
; Revision 1.1  2007/06/21 19:37:59  reduce
; Initial release. Karl B.
;
;-
version='$Id: scc_getbkgimg.pro,v 1.67 2011/07/21 21:52:36 nathan Exp $'

IF keyword_set(SILENT) THEN debugon=0 ELSE debugon=1
IF debugon THEN help,version
; Get the value of the INTERPOLATE keyword.  This may be changed below.

interp = keyword_set(k_interp)

; Do some verification, get camera, etc

del=get_delim()  ; get delimiter
;stop
IF (datatype(inhdr) NE 'STC') then inhdr=fitshead2struct(inhdr,/DASH2UNDERSCORE)

tel=trim(strupcase(inhdr.DETECTOR))
if strupcase(tel) eq 'EUVI' then cam = 'eu' else cam = $
  strlowcase(strmid(tel,0,1) + strmid(tel,strlen(tel)-1,1))

ishi = (cam EQ 'h1') or (cam EQ 'h2')

;  Added the following stuff so that this routine should work for MVI headers too
;  Karl B, 08/15/2007
tags_used=tag_names(inhdr) 
wOBS=where(tags_used EQ 'OBSRVTRY')
filename=inhdr.FILENAME
IF (wOBS EQ -1) THEN BEGIN
    ; This must be an mvi header.
    ; Try to get sc identifier from filename
    sc=strlowcase(rstrmid(filename,4,1))
ENDIF ELSE sc = strlowcase(strmid(inhdr.OBSRVTRY,7,1))

;  Make sure the spacecraft name is valid.
IF sc NE 'a' and sc NE 'b' THEN BEGIN
    PRINT,''
    PRINT,'ERROR!! Could not determine spacecraft from input header'
    PRINT,''
    return, 1
ENDIF

;--Check for processing level
islevelone=0
IF strmid(filename,16,1) EQ '1' THEN BEGIN
    islevelone=1
    match=0
    IF debugon THEN print,'Level-1 image detected.'
ENDIF

if keyword_set(raw_calroll) then begin
    ndays = 365
    rootdir = concat_dir(getenv('SECCHI_BKG'), sc + del + 'roll_min' + del)
    fchar = 'r'
end else if keyword_set(calroll) then begin
    ndays = 30
    rootdir = concat_dir(getenv('SECCHI_BKG'), sc + del + 'monthly_roll' + del)
    fchar = 'mr'
end else if keyword_set(daily) then begin
    ndays = 30
    rootdir = concat_dir(getenv('SECCHI_BKG'), sc + del + 'daily_med' + del)
    fchar = 'd'
end else begin
    ndays = 30
    rootdir = concat_dir(getenv('SECCHI_BKG'), sc + del + 'monthly_min' + del)
    fchar = 'm'
endelse

;  Form the polar search string, based on the angle in the header, or on the
;  keyword TOTALB.

;;polstring='_pTBr_'
polstring='_dbTB_'
polar=inhdr.polar
IF polar LT 361 and polar GE 0 and ~keyword_set(TOTALB) and inhdr.seb_prog NE 'DOUBLE' $
THEN polstring='_p'+string(round(polar),format='(I3.3)')+'_'
IF polar GT 361 and ~keyword_set(TOTALB) and inhdr.seb_prog EQ 'DOUBLE' THEN polstring='_dbTB_'

;;if debugon and polstring EQ '_pTBr_' and cam EQ 'c1' then BEGIN
;;    print
;;    PRINT, '%%SSC_GETBKGIMG: There are no TB background images made for COR1.'
;;    print, 'The default for SECCHI_PREP is to subtract a background for each'
;;    print, 'polarization angle before combining into TB. Returning.'
;;    print
;;    RETURN, -1
;;ENDIF

;  Get the date from the header, and look for a background file corresponding
;  to this date.

dtin=inhdr.DATE_AVG
cal = anytim2cal(dtin, form=8, /date)
sdir = strmid(cal,0,6)          ;Monthly directory name
sfil = strmid(cal,2,6)          ;Date part of file name

; days when stray light pattern changed are a special case.
; bkg for day of change will be new bkg
hhmm=strmid(filename,9,4)
;IF sfil EQ '110127' and sc EQ 'b' THEN IF hhmm LT '0353' THEN sfil='110126' ELSE interp=0

onemoretime:

filesrch0 = concat_dir(rootdir, sdir + del + fchar + cam + strupcase(sc) + $
                      polstring + sfil + '.fts')
files = file_search(filesrch0, count=count)

delvarx, bkgfile0, bkgfile1
if count gt 0 then begin
    bkgfile = files[0]
    if interp then bkgfile0=bkgfile else goto, read_file
    ; bkgfile0 is same day is input
endif

;  Otherwise, start looking backwards and forwards in time until a background
;  image is found.  When /INTERPOLATE is set, look for three images, so that
;  the two bracketing the date is set.

utcin = anytim2utc(dtin)
taiin = anytim2tai(utcin)

;  Set limits based on the major spacecraft repointings, or other major events.
;
; WARNING!!! Do not input date of event until there is a background available after that date!!!
;
case strupcase(sc) of
    'A': begin
        repoint = ['2006-12-21T13:15', '2007-02-03T13:15']
        if strupcase(tel) eq 'COR1' then repoint = $
          [repoint, '2010-01-27T16:49', '2010-11-19T16:00', $
           '2011-01-12T12:23', '2011-02-11T04:23', '2011-03-08T17']
    endcase
    'B': begin
        repoint = ['2007-02-03T18:20', '2007-02-21T20:00']
        if strupcase(tel) eq 'COR1' then repoint = $
          [repoint, '2009-01-30T16:20', '2010-03-24T01:17', '2011-03-11']
        if strupcase(tel) eq 'COR2' then repoint = $
          [repoint, '2010-02-23T08:12', '2011-01-27T03:47','2011-04-25t18:30']
    endcase
endcase

;  Treat change to 512x512 as repoint, except for raw calibration rolls.  This
;  exception is made to allow calibration roll data to be used across the
;  boundary.

if (strupcase(tel) eq 'COR1') and not keyword_set(raw_calroll) then begin
    repoint = [repoint, '2009-04-18T23:59:59']
    s = sort(repoint)
    repoint = repoint[s]
endif

repoint = anytim2utc(repoint)
tai_repoint = utc2tai(repoint)
i1 = max(where(tai_repoint lt taiin, tcount))
if tcount gt 0 then mjdmin = repoint[i1].mjd else mjdmin = 0
i2 = min(where(tai_repoint gt taiin, tcount))
if tcount gt 0 then mjdmax = repoint[i2].mjd else mjdmax = 99999

;  Start searching

nsearch = 0
IF debugon THEN help,dtin
while nsearch lt ndays do begin
    nsearch = nsearch + 1
    fn1='--------------------'
    fn2='--------------------'
;
;  Look before the header date.
;
    utc = utcin
    utc.mjd = utcin.mjd - nsearch
    ymd1=utc2yymmdd(utc)
    if (utc.mjd gt mjdmin) and (utc.mjd lt mjdmax) then begin
        cal = anytim2cal(utc, form=8, /date)
        sdir = strmid(cal,0,6)  ;Monthly directory name
        sfil = strmid(cal,2,6)  ;Date part of file name
	fn1=fchar + cam + strupcase(sc) + polstring + sfil + '.fts'
        files1 = file_search(concat_dir(rootdir, sdir + del + fn1), count=count1)
    end else count1 = 0
;	help,fn1
;
;  And after the header date.
;
    utc = utcin
    utc.mjd = utcin.mjd + nsearch
    ymd2=utc2yymmdd(utc)
    if (utc.mjd gt mjdmin) and (utc.mjd lt mjdmax) then begin
        cal = anytim2cal(utc, form=8, /date)
        sdir = strmid(cal,0,6)  ;Monthly directory name
        sfil = strmid(cal,2,6)  ;Date part of file name
	fn2=fchar + cam + strupcase(sc) + polstring + sfil + '.fts'
        files2 = file_search(concat_dir(rootdir, sdir + del + fn2), count=count2)
    end else count2 = 0
;	help,fn2
;
;  If files are found for both before and after, then pick the file closest in
;  time.  If the interpolate keyword is set, and the first background file
;  hasn't been picked yet, then take both files.
;
;IF debugon THEN print,nsearch,' ',ymd1,' ',ymd2,byte(count1),byte(count2),' ',fn1,' ',fn2

    if (count1 gt 0) and (count2 gt 0) then begin
        if interp and (n_elements(bkgfile0) eq 0) then begin
            bkgfile0 = files1[0]
            bkgfile  = files2[0]
	    closestisbefore=1
            goto, read_file
        endif
        dummy = sccreadfits(files1[0], h1, /nodata)
        dummy = sccreadfits(files2[0], h2, /nodata)
	IF h1.date_avg NE '' THEN h1t=h1.date_avg ELSE h1t=h1.date_obs
	IF h2.date_avg NE '' THEN h2t=h2.date_avg ELSE h2t=h2.date_obs
        dtai1 = taiin - anytim2tai(h1t)
        dtai2 = anytim2tai(h2t) - taiin
        if dtai2 lt dtai1 then begin
            bkgfile_found = files2[0]
	    closestisbefore=0
            goto, file_found
        end else begin
            bkgfile_found = files1[0]
	    closestisbefore=1
            goto, file_found
        endelse
;
;  Otherwise, take the file that was found.
;
    end else if count1 gt 0 then begin
        bkgfile_found = files1[0]
	closestisbefore=0
        goto, file_found
    end else if count2 gt 0 then begin
        bkgfile_found = files2[0]
	closestisbefore=1
        goto, file_found
    endif
;
    goto, next_date
;
;  Process the found file based on whether one is interpolating or not.
;
    file_found:
    
    bkgfile = bkgfile_found
    if interp then begin
        if n_elements(bkgfile0) eq 0 then begin
            bkgfile0 = bkgfile
        end else if n_elements(bkgfile1) eq 0 then begin
            bkgfile1 = bkgfile
            goto, read_file
        endif
    end else goto, read_file
    ;
    next_date:
endwhile

;  If /INTERPOLATE was set, and only one file was found, then proceed as if
;  /INTERPOLATE was not set.

if interp and (n_elements(bkgfile0) eq 1) then begin
    IF ~keyword_set(silent) THEN print, $
      'Only one background file found -- not interpolating'
    interp = 0
    bkgfile = bkgfile0
    goto, read_file
endif

if polstring EQ '_dbTB_' then begin  ; look for cor2 pTBr if double is not found
   message,'No '+polstring+' models found near: '+sfil+'; trying _pTBr_ instead...',/info
   polstring='_pTBr_'
   wait,2
   goto, onemoretime
endif

;  If no files were found, return an error message.

if ~keyword_set(silent) then PRINT, $
  '%%SSC_GETBKGIMG: No models found near: ', filesrch0
wait,10
RETURN, -1

;  Read in the background file(s).  If /INTERPOLATE was set, and three files
;  were found, then choose the two files which bracket the observation date,
;  based on the filename.

READ_FILE:
if interp then begin
    IF ~keyword_set(silent) THEN print, 'reading closest to interp: '
    IF ~keyword_set(silent) THEN print, bkgfile0
    ; This is the closest file to input, could be before OR after
    IF (islevelone) and not ishi THEN  $
	; HI is special case
	SECCHI_PREP,bkgfile0,outhdr0,bkgimg0,WARP_OFF=(inhdr.DISTCORR EQ 'F'), OUTSIZE=2048/(2^(inhdr.summed-1)) ELSE $
    	bkgimg0 = SCCREADFITS(bkgfile0, outhdr0, silent=silent)
    IF outhdr0.date_avg NE '' THEN date_avg0=outhdr0.date_avg ELSE date_avg0=outhdr0.date_obs
    if n_elements(bkgfile1) eq 1 then begin
        bkgfile2 = bkgfile
        bkgfile  = bkgfile1
        break_file, bkgfile0, disk0, dir0, name0
        d0 = '20' + strmid(name0,10,6)
        break_file, bkgfile1, disk1, dir1, name1
        d1 = '20' + strmid(name1,10,6)
        break_file, bkgfile,  disk2, dir2, name2
        d2 = '20' + strmid(name2,10,6)
        d = anytim2cal(inhdr.date_obs,form=8,/date)
        if ((d gt d0) and (d gt d1) and (d lt d2)) or $
          ((d lt d0) and (d lt d1) and (d gt d2)) then bkgfile = bkgfile2
    endif
endif    

;IF ~keyword_set(silent) THEN help,bkgfile,bkgfile0,bkgfile1,bkgfile2
IF ~keyword_set(silent) THEN print, 'reading: '
IF ~keyword_set(silent) THEN print, bkgfile
IF (islevelone) and not ishi THEN $
    SECCHI_PREP,bkgfile,outhdr,bkgimg,WARP_OFF=(inhdr.DISTCORR EQ 'F'), OUTSIZE=2048/(2^(inhdr.summed-1)) ELSE $
    bkgimg = SCCREADFITS(bkgfile, outhdr, silent=silent)
IF outhdr.date_avg NE '' THEN date_avg=outhdr.date_avg ELSE date_avg=outhdr.date_obs

; ++ Match size.  For integer reduction factors, use the
;  function REDUCE with /AVERAGE.  Otherwise, use REBIN
;  outhdr.summed set later

i_reduce = float(outhdr.naxis1) / inhdr.naxis1
j_reduce = float(outhdr.naxis2) / inhdr.naxis2

if (inhdr.naxis1 ne outhdr.naxis1) or (inhdr.naxis2 ne outhdr.naxis2) then begin
    if (i_reduce eq fix(i_reduce)) and (j_reduce eq fix(j_reduce)) then $
      bkgimg = reduce(bkgimg, i_reduce, j_reduce, /average)        else $
      bkgimg = rebin(temporary(bkgimg),inhdr.naxis1,inhdr.naxis2) 
endif

;  If /INTERPOLATE was set, perform the same action on the other background
;  image.

if interp then begin
    if (inhdr.naxis1 ne outhdr0.naxis1) or (inhdr.naxis2 ne outhdr0.naxis2) then begin
        i_reduce = float(outhdr0.naxis1) / inhdr.naxis1
        j_reduce = float(outhdr0.naxis2) / inhdr.naxis2
        if (i_reduce eq fix(i_reduce)) and (j_reduce eq fix(j_reduce)) then $
          bkgimg0 = reduce(bkgimg0, i_reduce, j_reduce, /average)        else $
          bkgimg0 = rebin(temporary(bkgimg0),inhdr.naxis1,inhdr.naxis2) 
    endif

;  Interpolate between the two images.

    if date_avg0 eq date_avg then begin
        bkgimg = bkgimg0 
        factor=1.0
    endif else begin
        tai0 = utc2tai((strsplit(date_avg0,' ',/extract))[0])
        tai1 = utc2tai((strsplit(date_avg ,' ',/extract))[0])
    	factor=(taiin-tai0)/(tai1-tai0)
    	IF ~keyword_set(SILENT) THEN help,date_avg0,date_avg,factor
	IF ~keyword_set(SILENT) and factor LT 0 THEN print,'Extrapolating...'
    	bkgimg = bkgimg0 + (bkgimg-bkgimg0)*factor
    endelse
    outhdr1= outhdr
    outhdr = outhdr0            ;Header of closest background image
    outhdr.date_avg=inhdr.date_avg
    outhdr.obt_time=factor  	; for testing
    IF (closestisbefore) THEN BEGIN
    	outhdr.date_obs=outhdr0.date_obs
	outhdr.date_end=outhdr1.date_end
    ENDIF ELSE BEGIN
    	outhdr.date_obs=outhdr1.date_obs
	outhdr.date_end=outhdr0.date_end
    ENDELSE
endif

;--All of this stuff gets set in SECCHI_PREP:

;if match check distcorr for bkgimg 
IF keyword_set(MATCH) and inhdr.DISTCORR eq 'T' and outhdr.DISTCORR eq 'F' THEN $
    bkgimg = cor2_warp(temporary(bkgimg),outhdr, INFO=histinfo, _EXTRA=ex)

IF ~(islevelone) THEN BEGIN
    outhdr.naxis1 = inhdr.naxis1
    outhdr.naxis2 = inhdr.naxis2
    outhdr.summed = inhdr.summed

    ;outhdr.CRPIX1 = 0.5+(outhdr.crpix1-0.5)/i_reduce
    ;outhdr.CRPIX1A= 0.5+(outhdr.CRPIX1A-0.5)/i_reduce
    ;outhdr.CRPIX2 = 0.5+(outhdr.crpix2-0.5)/j_reduce
    ;outhdr.CRPIX2A= 0.5+(outhdr.CRPIX2A-0.5)/j_reduce
    ;--Because crpix in bkg headers up until May 2008 are incorrect,
    ;  use value from inhdr
    outhdr.crpix1  = inhdr.crpix1
    outhdr.crpix2  = inhdr.crpix2
    outhdr.crpix1a = inhdr.crpix1a
    outhdr.crpix1a = inhdr.crpix1a
    outhdr.CDELT1  =  outhdr.CDELT1*i_reduce
    outhdr.CDELT2  =  outhdr.CDELT2*j_reduce
    outhdr.CDELT1A =  outhdr.CDELT1A*i_reduce
    outhdr.CDELT2A =  outhdr.CDELT2A*j_reduce
ENDIF
;---------------------------------------------------------------

outhdr.nmissing=0   ; nr, 080918 - if 0, breaks hi_prep.pro

goto, skiphdrcorrection
;
;   -- Correct for bad (early) headers, using input values
;
IF outhdr.biasmean LE 0 THEN outhdr.biasmean=inhdr.biasmean
IF tel EQ 'COR2' and (outhdr.polar GE 0 and outhdr.polar LE 360) and outhdr.offsetcr LE 0 THEN BEGIN
    ; these bkgs do not have bias subtracted
    outhdr.offsetcr=0.
ENDIF ELSE BEGIN
    outhdr.offsetcr=inhdr.biasmean
ENDELSE
IF tel EQ 'COR2' and outhdr.polar GT 1000 THEN outhdr.exptime=-1.   
; TBr combo images used to make bkg
IF (ishi) and inhdr.offsetcr LE 0 THEN inhdr.offsetcr=inhdr.biasmean
; HI images have bias subtracted onboard before summing
IF tel EQ 'HI1' THEN outhdr.exptime=1200.
IF tel EQ 'HI2' THEN outhdr.exptime=4950.
IF outhdr.summed LE 0 THEN BEGIN
    IF (ishi) THEN BEGIN
    	outhdr.summed=2.
	outhdr.ipsum=2
    ENDIF
    IF tel EQ 'COR1' THEN BEGIN
    	outhdr.summed=2.
	outhdr.ipsum=2
    ENDIF
    IF tel EQ 'COR2' THEN BEGIN
    	outhdr.summed=1.
	outhdr.ipsum=1
    ENDIF
ENDIF
;
;   --Done header correction
;
skiphdrcorrection:

;--Rotate IF difference greater than 1 degree

rolldif=inhdr.crota - outhdr.crota
IF ~keyword_set(SILENT) THEN help,rolldif
IF abs(rolldif) GT 1. and keyword_set(ROLL) THEN BEGIN
      bc=scc_sun_center(outhdr)
      ;bkgimg = rot(temporary(bkgimg),rolldif,1.0,bc.xcen,bc.ycen,missing=0,/cubic,/pivot,_extra=ex)
      bkgimg = rot(temporary(bkgimg),rolldif,1.0,outhdr.crpix1-1,outhdr.crpix2-1,missing=0,/cubic,/pivot,_extra=ex)
      ;update header
      outhdr.crota = inhdr.crota
      outhdr.PC1_1 = inhdr.PC1_1
      outhdr.PC1_2 = inhdr.PC1_2
      outhdr.PC2_1 = inhdr.PC2_1
      outhdr.PC2_2 = inhdr.PC2_2
      IF ~keyword_set(SILENT) THEN BEGIN
      	message,'Background rotated '+trim(rolldif)+' deg to match input header.',/info
    ENDIF
ENDIF ELSE IF ~keyword_set(SILENT) THEN message,'Background NOT rotated to match input header.',/info

;
;  Correct for double exposure  non-linearity effect. This is NOT done in SECCHI_PREP
;
    if inhdr.seb_prog EQ 'DOUBLE' and keyword_set(NONLINEARITYCORRECTION) THEN begin
        a0 = 1.04418
        a1 = -0.00645004
        scl = (a0 + a1*alog(abs(inhdr.exptime))) + a1*alog(bkgimg>1)
	print,'Computed non-linearity factor (only >1 used):'
	maxmin,scl
	bkgimg=bkgimg*(scl>1.)
    endif

IF keyword_set(MATCH) THEN BEGIN
    ;--All these are done in SECCHI_PREP
    ;
    ; ++ Match binning (not size)
    sumdif=inhdr.ipsum - outhdr.ipsum
    IF  sumdif NE 0  THEN BEGIN
    	binfac=4^(sumdif)
	IF ~keyword_set(SILENT) THEN message,'Background corrected for binning * '+trim(binfac),/info
	bkgimg=bkgimg*binfac
	outhdr.ipsum=inhdr.ipsum
    ENDIF

    ; ++ Match exptime
    bkgimg=bkgimg*abs(inhdr.exptime/outhdr.exptime)

    ; ++ Match bias state in OFFSETCR keyword
    ;    secchi_prep removes bias BEFORE ipsum correction
    ;    hi never has bias correction because it is done onboard
    IF (not ishi) THEN IF inhdr.offsetcr GT 0 and outhdr.offsetcr LE 0 THEN BEGIN
	; subtract bias
	IF ~keyword_set(silent) THEN print,'subtracting bias...'
	bkgimg=bkgimg-outhdr.biasmean*4^sumdif
	outhdr.offsetcr=outhdr.biasmean*4^sumdif
    ENDIF
    IF (not ishi) THEN IF inhdr.offsetcr LE 0 and outhdr.offsetcr GT 0 THEN BEGIN
	; add bias back in
	IF ~keyword_set(silent) THEN print,'adding bias...'
	bkgimg=bkgimg+outhdr.biasmean*4^sumdif
	outhdr.offsetcr=outhdr.offsetcr-outhdr.biasmean*4^sumdif
    ENDIF
;stop
    ; ++ Update bkg header
    outhdr.summed=inhdr.summed
    outhdr.exptime=abs(inhdr.exptime)
    
ENDIF

;
; ++ Do HI level-1 correction
;
IF ishi and islevelone THEN BEGIN
; NOTE: this will not work if input header had /UPDATE_HDR_OFF
    IF strlen(grep('Flat Field',inhdr.history)) GT 1 THEN nocalimg=0 ELSE nocalimg=1
    IF strlen(grep('calibration factor',inhdr.history)) GT 1 THEN nocalfac=0 ELSE nocalfac=1
    IF strlen(grep('exposure weighting',inhdr.history)) GT 1 THEN nodesmear=1 ELSE nodesmear=0
    noexpcorr=1
    IF strlen(grep('desmearing method',inhdr.history)) GT 1 or nodesmear THEN noexpcorr=0
    help,nocalimg,noexpcorr,nocalfac,nodesmear
    bk0=bkgimg
    inhdr1=inhdr
    inhdr1.ipsum=2.
    inhdr1.bunit='DN'
    bkgimg=bkgimg*inhdr.exptime*4.
    hi_prep,inhdr1,bkgimg, saturation_limit=16384, calimg_off=nocalimg, DESMEAR_OFF=nodesmear, $
    	EXPTIME_OFF=noexpcorr, OUTSIZE=outhdr.naxis1,  SILENT=quiet, calfac_off=nocalfac

ENDIF


;
; ++ Match subfield
;
; TBD


;  Return the background image.

IF ~keyword_set(silent) THEN maxmin,bkgimg

return, bkgimg

END
