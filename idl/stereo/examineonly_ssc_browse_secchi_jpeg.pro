;+
; Project     :	STEREO - SSC
;
; Name        :	SSC_BROWSE_SECCHI_JPEG
;
; Purpose     :	Process SECCHI beacon images for the web
;
; Category    :	SECCHI, Quicklook
;
; Explanation :	Called from SSC_BEACON_SECCHI to generate JPEG images at
;               various resolutions.
;
; Syntax      :	SSC_BROWSE_SECCHI_JPEG, FILE, NAME, SC, STEREO_BROWSE, SDATE
;
; Examples    :	See SSC_BEACON_SECCHI
;
; Inputs      :	FILE    = FITS file to process
;               NAME    = Base filename without directory or extension
;               SC      = Either "ahead" or "behind"
;               STEREO_BROWSE = Top browse directory
;
; Opt. Inputs :	None.
;
; Outputs     :	None required.
;
; Opt. Outputs:	SDATE   = Returns date if file was processed.
;
; Keywords    :	BEACON  = Set to true if one is processing beacon data.
;
;               REPLACE = If set, then replace existing JPEG files
;
;               COR_REPLACE = Replace coronagraph JPEG files (including HI)
;
;               OLDDIR  = Used together with /BEACON to recreate previously
;                         deleted beacon images in "beacon" subdirectories.
;
; Env. Vars.  :	None.
;
; Calls       :	CONCAT_DIR, BREAK_FILE, FXHREAD, FXPAR, STR2UTC, FXREAD,
;               SCC_IMG_TRIM, EUVI_PREP, SCC_BYTSCL, SCC_FITSHDR2STRUCT
;               UTC2STR, SSC_SECCHI_CAPTION, SSC_SECCHI_DIR_HTML, IS_FITS
;               GET_STEREO_HPC_POINT, SSC_BEACON_JPLOT_COR2,
;               SSC_BEACON_JPLOT_HI1, SSC_BEACON_JPLOT_HI2,
;               SSC_REMOVE_SECCHI_BEACON
;
; Common      :	None.
;
; Restrictions:	Currently, this procedure only handles EUVI, COR1, COR2 images.
;
; Side effects:	The graphics device is set to the Z buffer
;
; Prev. Hist. :	Partially based on EUVI_PRETTY by Jean-Pierre Wuelser
;
; History     :	Version 1, 21-Mar-2007, William Thompson, GSFC
;                       split off from SSC_BEACON_SECCHI
;               Version 2, 29-Mar-2007, William Thompson, GSFC
;                       use fxread for catching errors
;                       rotate about image center
;                       added keyword REPLACE
;               Version 3, 12-Apr-2007, William Thompson, GSFC
;                       Use EUVI_PREP & SCC_BYTSCL.
;                       Use smaller fonts on the larger images
;               Version 4, 13-Apr-2007, WTT, filter out bad images
;               Version 5, 16-Apr-2007, WTT, ... and incomplete images
;                       Use GET_STEREO_HPC_POINT
;               Version 6, 06-Jul-2007, WTT, Add support for COR1
;               Version 7, 12-Jul-2007, WTT, Added keyword COR_REPLACE
;               Version 8, 16-Jul-2007, WTT, Big fix for overriding SWx images
;               Version 9, 01-Aug-2007, WTT, Add COR2 support
;               Version 10, 09-Aug-2007, WTT, adjust COR2 double exposures
;               Version 11, 10-Aug-2007, WTT, add support for HI
;               Version 12, 13-Aug-2007, WTT, make sure COR images are trimmed
;               Version 13, 20-Aug-2007, WTT, correct header bug for CORs
;               Version 14, 06-Sep-2007, WTT, handle HI SWx images
;               Version 15, 20-Sep-2007, WTT, use IPSUM instead of SUMMED
;               Version 16, 26-Sep-2007, WTT, change COR2B parameters
;               Version 17, 10-Oct-2007, WTT, add /BKGIMG_OFF
;               Version 18, 24-Oct-2007, WTT, interpolate COR1 bkg images
;               Version 19, 21-Nov-2007, WTT, Use HI_PREP for new backgrounds
;               Version 20, 18-Dec-2007, WTT, Include HI2 difference images.
;               Version 21, 02-Jan-2008, WTT, increase HI2 contrast
;               Version 22, 01-Feb-2008, WTT, Adjust COR2B parameters.
;               Version 23, 04-Mar-2008, WTT, Better filtering of bad images
;               Version 24, 14-May-2008, WTT, Treat early HI*B,COR2B images
;               Version 25, 16-May-2008, WTT, COR1 images and backgrounds must
;                                             have same value of CCDSUM
;               Version 26, 09-Jun-2008, WTT, Add /NOWARP for COR2
;               Version 27, 18-Jul-2008, WTT, Boost COR2-B beacon images
;               Version 28, 24-Feb-2008, WTT, Remove /NOWARP except for beacon
;                                             Add keyword /COR2_REPLACE
;               Version 29, 25-Feb-2008, WTT, Smaller median for beacon images
;               Version 30, 13-May-2009, WTT, reverted to version 29
;                       Don't assume IPSUM=2 for COR1 background image
;               Version 31, 23-Jun-2009, WTT, Better removal of COR2 SWx images
;               Version 32, 07-Jul-2009, WTT, Call COR2 and HI1 Jplot routines
;               Version 33, 17-Aug-2009, WTT, Include HI2 beacon images
;               Version 34, 20-Oct-2009, WTT, Don't process COR2 "flag" images
;               Version 34, 13-Apr-2010, WTT, Refine detection of flag images
;               Version 35, 28-Feb-2011, WTT, Call SSC_REMOVE_SECCHI_BEACON.
;                                             Add /OLDDIR keyword
;
; Contact     :	WTHOMPSON
;-
;
pro ssc_browse_secchi_jpeg, file, name, sc, stereo_browse, sdate, $
                            beacon=beacon, olddir=olddir, replace=replace, $
                            cor_replace=cor_replace, no_euvi=no_euvi, $
                            cor2_replace=cor2_replace, $
                            cor2b_replace=cor2b_replace, $
                            hi2_replace=hi2_replace, euvi_replace=euvi_replace
;
;  Set up some arrays.
;
sdate = ''
res = [2048,1024,512,256,128]
;;charsize = [8,4,2,1,0.5]
;;charthick = [4,2,1,1,1]
charsize = [4,2,2,1,0.5]
charthick = [2,1,1,1,1]
ires0 = 0
;
;  Get the modification date of the file.  Also, make sure that the file has
;  data in it, and extract some minimal information from the header.
;
if not is_fits(file) then return
openr, unit, file, /get_lun
mtime0 = (fstat(unit)).mtime
fxhread, unit, textheader
free_lun, unit
if fxpar(textheader, 'doorstat') eq 0 then return       ;Door closed
if fxpar(textheader, 'nmissing') gt 0 then return       ;Incomplete image.
date_obs = fxpar(textheader, 'date-obs')
detector = strlowcase(strtrim(fxpar(textheader, 'detector'),2))
if (detector eq 'euvi') and keyword_set(no_euvi) then return
if (detector eq 'cor1') or (detector eq 'hi1') or (detector eq 'hi2') then $
  ires0 = 1                     ;No 2048x2048 version
wavelnth = fxpar(textheader, 'wavelnth')
if wavelnth eq 175 then wavelnth = 171
file_read = 0
date_obs = str2utc(date_obs, /external)
;
;  Step through the resolutions and form the name of the output file.
;
for ires = ires0,n_elements(res)-1 do begin
    jpeg_path = concat_dir(stereo_browse, $
                           string(date_obs.year, format='(I4.4)')  + '/' + $
                           string(date_obs.month, format='(I2.2)') + '/' + $
                           string(date_obs.day, format='(I2.2)')   + '/' + $
                           sc + '/' + detector)
    if detector eq 'euvi' then jpeg_path = $
      concat_dir(jpeg_path, string(wavelnth, format='(I3.3)'))
    jpeg_path = concat_dir(jpeg_path, ntrim(res[ires]))
    if keyword_set(olddir) then jpeg_path = concat_dir(jpeg_path, 'beacon')
    jpeg_file = concat_dir(jpeg_path, name)
    if detector eq 'euvi' then jpeg_file = jpeg_file + '_' + $
      string(wavelnth, format='(I3.3)')
    jpeg_file = jpeg_file + '.jpg'
;
;  Get the modification time of the file.  If the file doesn't exist, check to
;  see if there's already a full-resolution version of the same file.
;  Otherwise, fake a modification time earlier than that of the FITS file so
;  that the JPEG will be created.
;
    if file_exist(jpeg_file) then begin
        openr, unit, jpeg_file, /get_lun
        mtime1 = (fstat(unit)).mtime
        free_lun, unit
    end else begin
        break_file, jpeg_file, disk0, dir0, name0, ext0
        strput, name0, '??', 16
        temp = file_search(disk0+dir0+name0+ext0, count=count)
        if count gt 0 then begin
            break_file, temp, disk1, dir1, name1
            w = where(strmid(name1, 17, 1) ne '7', ccount)
            if ccount gt 0 then mtime1=2*mtime0 else mtime1=0
        end else mtime1 = 0
    endelse
;
;  If the JPEG modification time is earlier than the FITS modification time,
;  then create the JPEG file.
;
    if (mtime0 gt mtime1) or keyword_set(replace) or $
      ((detector ne 'euvi') and keyword_set(cor_replace)) or $
      ((detector eq 'euvi') and keyword_set(euvi_replace)) or $
      ((detector eq 'hi2') and keyword_set(hi2_replace)) or $
      ((detector eq 'cor2') and keyword_set(cor2_replace)) or $
      ((detector eq 'cor2') and (sc eq 'behind') and $
       keyword_set(cor2b_replace)) then begin
;
;  If not already done, read in the FITS file, and form the image.  Restrict to
;  the active area of the CCD.  Reading of the COR1 and COR2 images is deferred
;  to later in the program.
;
        if not file_read then begin
            errmsg = ''
            if (detector eq 'cor1') or (detector eq 'cor2') then $
              header = scc_fitshdr2struct(textheader) else begin
                fxread, file, image, header, errmsg=errmsg
                if errmsg ne '' then begin
                    print, errmsg
                    return      ;Skip if file is unreadable
                endif
                header = scc_fitshdr2struct(header)
                image = scc_img_trim(image, header,/silent)
            endelse
            file_read = 1
;
;  Process the image based on the detector type.
;
            case detector of
                'euvi': begin
;
;  Use the statistics in the corner of the image to decide whether or not to
;  process this image.
;
                    stat = fltarr(4)
                    sz = size(image)
                    stat[0] = stddev(median(image[1:62, 1:62],3))
                    stat[1] = stddev(median(image[1:62, sz[2]-63:sz[2]-2],3))
                    stat[2] = stddev(median(image[sz[1]-63:sz[1]-2, 1:62],3))
                    stat[3] = stddev(median(image[sz[1]-63:sz[1]-2, $
                                                  sz[2]-63:sz[2]-2],3))
                    if keyword_set(beacon) then mstat=100 else mstat=10
                    if median(stat) gt mstat then return
;
;  Call EUVI_PREP to prepare the image for display.  Load the color table.
;
                    euvi_prep, header, image, /color_on, /calimg_off, $
                               /update_hdr_off, /silent
;
;  Rotate the image.
;
                    sz = size(image)
                    temp = fltarr(sz[1]+2,sz[2]+2)
                    temp[1,1] = image
                    point = get_stereo_hpc_point(header.date_obs, sc)
                    image = rot(temp, -point[2], 1)
                    image = image[1:sz[1], 1:sz[2]]
;
;  Scale the image.
;
                    image = scc_bytscl(image, header)
                endcase
;
;  Process COR1 images.
;
                'cor1': if header.polar eq 240 then begin
;
;  Filter out early images known to be bad.
;
                    if (sc eq 'ahead') and (header.date_obs lt '2007-01-05') $
                      and (header.naxis1 lt 1000) then return
;
;  Find the three files leading up to this image.
;
                    break_file, file, disk0, dir0, name0
                    files = '*' + strmid(name0,strlen(name0)-6,6) + '.fts'
                    files = file_search(concat_dir(disk0+dir0,files))
                    w = (where(files eq file))[0]
                    if w lt 2 then return
                    files = files[w-2:w]
                    break_file, files, disk1, dir1, name1
                    if total(scc_check_bad(name1)) gt 0 then return
                    time = strmid(name1,13,2) + strmid(name1,11,2)*60 + $
                      strmid(name1,9,2)*3600
                    delta = max(time,min=tmin) - tmin
                    if delta gt 120 then return
;
;  Read in the three files, and use COR_PREP to prepare the image for display.
;
                    image = 0
                    for i=0,2 do begin
                        fxread, files[i], a, h, errmsg=errmsg
                        if errmsg ne '' then begin
                            print, errmsg
                            return ;Skip if file is unreadable
                        endif
;
;  Use the statistics in the corner of the image to decide whether or not to
;  process this image.
;
                        if fxpar(h,'nmissing') gt 0 then return
                        stat = fltarr(4)
                        sz = size(a)
                        stat[0] = stddev(median(a[1:10, 1:10],3))
                        stat[1] = stddev(median(a[1:10, sz[2]-11:sz[2]-2],3))
                        stat[2] = stddev(median(a[sz[1]-11:sz[1]-2, 1:10],3))
                        stat[3] = stddev(median(a[sz[1]-11:sz[1]-2, $
                                                  sz[2]-11:sz[2]-2],3))
                        if keyword_set(beacon) then mstat=10 else mstat=5
                        if median(stat) gt mstat then return
;
;  Use COR_PREP to prepare the image for display.
;
                        a = scc_img_trim(a, h,/silent)
                        cor_prep, h, a, /calimg_off, /calfac_off, $
                          /update_hdr_off, /bkgimg_off, /silent
;
;  Get the background image and subtract it.
;
                        daily = 0
                        if (sc eq 'ahead') and $
                          (header.date_obs lt '2007-02-03') then daily = 1
                        interpolate = 1
                        if (sc eq 'behind') and $
                           (header.date_obs lt '2007-02-17') then $
                          interpolate = 0
                        bkg = scc_getbkgimg(h, /silent, daily=daily, $
                                            interpolate=interpolate, $
                                            outhdr=bkghdr)
                        if n_elements(bkg) le 1 then return ;no background
                        if h.ccdsum ne bkghdr.ccdsum then return
                        scl = 4^(h.ipsum-bkghdr.ipsum)
                        bkg = bkg * scl
;
;  Form the total brightness image from the sum of the images.
;
                        image = image + a - bkg
                    endfor
;
;  Rotate the image about Sun center.
;
                    sz = size(image)
                    temp = fltarr(sz[1]+2,sz[2]+2)
                    temp[1,1] = image
                    point = get_stereo_hpc_point(h.date_obs, sc)
                    wcs = fitshead2wcs(h)
                    center = wcs_get_pixel(wcs, [0,0])
                    image = rot(temp, -point[2], 1, center[0], center[1], $
                                /pivot)
                    image = image[1:sz[1], 1:sz[2]]
;
;  Load the color table, and scale the image.
;
                    loadct, 8, /silent  &  gamma_ct, 0.4
                    image = bytscl(sigrange(image,fraction=.995), min=0)
                endif else return       ;if not 240 degrees
;
;  Process COR2 images.
;
                'cor2': if (header.seb_prog eq 'DOUBLE') or $
                  (header.polar eq 240) then begin
;
;  Don't process COR2 images with exposure times longer than 20 seconds.  These
;  are "extra" images.
;
                    if header.exptime ge 20 then return
;
;  Don't process non-beacon images smaller than 512x512, or with exposure times
;  less than 5 seconds after 2009-06-01.  These are "extra" images used for
;  generating CME flags.
;
                    if (not keyword_set(beacon)) and $
                      ((header.naxis1 lt 512) or $
                       ((header.exptime lt 5) and $
                        (header.date_obs gt '2009-06-01'))) then return
;
;  Define the relative min and max values.  These get modified depending on
;  the spacecraft and kind of image.
;
                    amin = 0.95
                    amax = 1.15
                    if header.obsrvtry eq 'STEREO_B' then begin
                        if keyword_set(beacon) then amin = 0.9625 else $
                          amin = 0.975
                        amax = 1.11250
                    endif
;
;  If not a double exposure, find the three files leading up to this image.
;
                    if header.seb_prog ne 'DOUBLE' then begin
                        break_file, file, disk0, dir0, name0
                        files = '*' + strmid(name0,strlen(name0)-6,6) + '.fts'
                        files = file_search(concat_dir(disk0+dir0,files))
                        w = (where(files eq file))[0]
                        if w lt 2 then return
                        files = files[w-2:w]
                        break_file, files, disk1, dir1, name1
                        if total(scc_check_bad(name1)) gt 0 then return
                        time = strmid(name1,13,2) + strmid(name1,11,2)*60 + $
                               strmid(name1,9,2)*3600
                        delta = max(time,min=tmin) - tmin
                        if delta gt 120 then return
                    end else files = file
;
;  Read in the file(s)
;
                    image = 0
                    for i=0,n_elements(files)-1 do begin
                        fxread, files[i], a, h, errmsg=errmsg
                        if errmsg ne '' then begin
                            print, errmsg
                            return ;Skip if file is unreadable
                        endif
;
;  Use the statistics in the corner of the image to decide whether or not to
;  process this image.
;
                        if fxpar(h,'nmissing') gt 0 then return
                        stat = fltarr(4)
                        sz = size(a)
                        stat[0] = stddev(median(a[1:10, 1:10],3))
                        stat[1] = stddev(median(a[1:10, sz[2]-11:sz[2]-2],3))
                        stat[2] = stddev(median(a[sz[1]-11:sz[1]-2, 1:10],3))
                        stat[3] = stddev(median(a[sz[1]-11:sz[1]-2, $
                                                  sz[2]-11:sz[2]-2],3))
                        if keyword_set(beacon) then mstat=10 else mstat=5
                        if median(stat) gt mstat then return
;
;  Use COR_PREP to prepare the image for display.
;
                        h = scc_fitshdr2struct(h)
                        if h.biasmean lt 400 then h.biasmean = 2 * h.biasmean
                        a = scc_img_trim(a, h,/silent)
                        cor_prep, h, a, /calimg_off, /calfac_off, $
                          /update_hdr_off, /silent, /smask, $
                          nowarp=keyword_set(beacon)
                        dsatval = 4.^(h.ipsum-1) * 2500
                        w = where((a eq 0) or (a gt dsatval), count)
                        if count gt 0 then flag_missing, a, w
;
;  Form the total brightness image from the sum of the images.
;
                        image = image + a
                    endfor
;
;  Properly scale brightness images formed from polarization sequences.
;
                    if n_elements(files) eq 3 then image = 2 * image / 3
;
;  Take out the effect of binning.
;
                    if h.ipsum ne 1 then begin
                        scl = 4^(h.ipsum-1)
                        image = image / scl
                    endif
;
;  Correct double exposure images for the non-linearity effect.
;
                    if n_elements(files) eq 1 then begin
                        a0 = 1.04418
                        a1 = -0.00645004
                        scl = (a0 + a1*alog(h.exptime)) + a1*alog(image>1)
                        image = image / (scl > 1)
                    endif
;
;  Get the background image and divide it.  For Behind images before March 8,
;  2007, do a subtraction instead, and use a different range.
;
                    bkg = scc_getbkgimg(h,/silent,/totalb)
                    if n_elements(bkg) le 1 then return ;no background
                    if keyword_set(beacon) then nmedian = 3 else nmedian = 5
                    if (sc eq 'behind') and (header.date_obs lt '2007-03-08') $
                      then begin
                        image = median(image - bkg, nmedian)
                        amin = -10
                        amax = 100
                    end else image = median(image / bkg, nmedian)
;
;  Rotate the image about Sun center.
;
                    sz = size(image)
                    point = get_stereo_hpc_point(h.date_obs, sc)
                    wcs = fitshead2wcs(h)
                    center = wcs_get_pixel(wcs, [0,0])
                    image = rot(image, -point[2], 1, center[0], center[1], $
                                /pivot, missing=!values.f_nan)
;
;  Load the color table, and scale the image.
;
                    loadct, 3, /silent
                    image = bytscl(image, min=amin, max=amax, /nan)
;
;  If a beacon image, then call SSC_BEACON_JPLOT_COR2.
;
                    if keyword_set(beacon) then ssc_beacon_jplot_cor2, files
                endif else return
;
;  Process HI1 images
;
                'hi1': if strmid(name,16,1) eq 's' then begin
                    hi_prep, header, image, /desmear_off, /update_hdr_off, $
                      /calimg_off, /silent
                    bkg = scc_getbkgimg(header,/silent)
                    if n_elements(bkg) le 1 then return ;no background
                    if keyword_set(beacon) then nmedian = 3 else nmedian = 5
                    image = median(image / bkg, nmedian)
                    if keyword_set(beacon) then begin
                        med = median(image)
                        if med lt 0 then begin
                            image = -image
                            med = -med
                        endif
                    end else begin
                        w = where((image gt 0) and (image lt 2), count)
                        if count eq 0 then begin
                            print, 'Background incompatible with ' + file
                            return
                        endif
                        med = median(image[w])
                    endelse
                    loadct, 1, /silent
                    gamma_ct, 0.6
;
;  Treat early HI1B images separately.
;
                    if (sc eq 'behind') and (header.date_obs lt '2007-03-28') $
                      then image = bytscl(sigrange(image)) else $
                      image = bytscl(image, min=0.96*med, max=1.08*med)
;
;  If a beacon image, then call SSC_BEACON_JPLOT_HI1.
;
                    if keyword_set(beacon) then ssc_beacon_jplot_hi1, file
                endif else return
;
;  Process HI2 images as difference images.  Find the image from 2 hours
;  earlier.  For Behind images before Feb 17, 2007, only display simple images.
;
                'hi2': if (strmid(name,16,1) eq 's') then begin
                    if (sc eq 'behind') and (header.date_obs lt '2007-02-17') $
                      then begin
                        loadct, 0, /silent
                        image = bytscl(sigrange(image))
                    end else begin
                        date0 = anytim2utc(header.date_obs, /ext)
                        date0.hour = date0.hour - 2
                        date0.minute = date0.minute - 10
                        check_ext_time, date0
                        date1 = date0
                        date1.minute = date1.minute + 20
                        check_ext_time, date1
                        cat = scc_read_summary(date=[date0,date1], spacecraft=sc, $
                                               telescope='hi2', beacon=beacon, $
                                               /check)
                        if datatype(cat,1) ne 'Structure' then return
                        w = where(strmid(cat.filename, 16, 1) eq 's', count)
                        if count eq 0 then return
;
                        hi_prep, header, image, /desmear_off, /update_hdr_off, $
                          /calimg_off, /calfac_off, /silent
                        errmsg = ''
                        fxread, sccfindfits(cat[w[0]].filename, beacon=beacon), $
                          bkg, hbkg, errmsg=errmsg
                        if errmsg ne '' then begin
                            print, errmsg
                            return ;Skip if file is unreadable
                        endif
                        hbkg = scc_fitshdr2struct(hbkg)
                        bkg = scc_img_trim(bkg, hbkg,/silent)
                        hi_prep, hbkg, bkg, /desmear_off, /update_hdr_off, $
                          /silent, /calimg_off, /calfac_off
;
;  If one is processing beacon images, then do a simple difference
;
                        if keyword_set(beacon) then begin
                            image = median(image - bkg, 3)
                        end else begin
;
;  Split the previous image up into diffuse (a0m) and sharp (a0) parts.
;
                            wcs = fitshead2wcs(header)
                            wcs0 = fitshead2wcs(hbkg)
                            a0m = median(bkg, 15)
                            a0 = bkg - a0m
;
;  Interpolate the sharp part based on the change in time.
;
                            coord = wcs_get_coord(wcs)
                            convert_stereo_lonlat, header.date_obs, coord, 'HPC', $
                              'GEI', /degrees, spacecraft=sc
                            convert_stereo_lonlat, hbkg.date_obs, coord, 'GEI', $
                              'HPC', /degrees, spacecraft=sc
                            pixel = wcs_get_pixel(wcs0, coord)
                            a0 = reform(interpolate(a0, pixel[0,*,*], pixel[1,*,*], $
                                                    missing=0, /cubic))
                            image = median(image - a0 - a0m, 3)
                        endelse
;
                        loadct, 0, /silent
                        if keyword_set(beacon) then imax=120 else imax=0.3
                        image = bytscl(image, min=-imax, max=imax)
                    endelse
;
;  If a beacon image, then call SSC_BEACON_JPLOT_HI2.
;
                    if keyword_set(beacon) then ssc_beacon_jplot_hi2, file
                endif else return
;
                else: return    ;Skip unhandled detectors
            endcase
;
;  Print a message about processing the file.  This print statement was moved
;  down here so that it only gets printed if the file is actually processed.
;
            print, 'Processing ' + file
        endif                   ;Code to read and process image
;
;  If necessary, create the JPEG directory.
;
        if not file_exist(jpeg_path) then mk_dir, jpeg_path
;
;  Return the processed date.
;
        sdate = utc2str(date_obs, /date_only)
;
;  Display the image in the Z-buffer, and put on the labels.
;
        temp = rebin(image, res[ires], res[ires])
        if !d.name ne 'Z' then set_plot,'Z'
        device, set_resolution=[res[ires],res[ires]]
;;        tvlct, rr, gg, bb
        tv, temp
        if header.obsrvtry eq 'STEREO_A' then $
          label = 'Ahead' else label = 'Behind'
        label = 'STEREO ' + label + ' ' + header.detector
        if detector eq 'euvi' then label = label + ' ' + $
          string(wavelnth, format='(I3.3)')
        ysize = !d.y_ch_size * charsize[ires]
        xyouts, res[ires]/2, res[ires] - 1.5*ysize, label, $
          charsize=charsize[ires], color=!d.table_size-1, $
          charthick=charthick[ires], alignment=0.5, /device
        xyouts, res[ires]/2, 0.5*ysize, charsize=charsize[ires], $
          sdate + ' ' + utc2str(date_obs, /time_only, /truncate), $
          color=!d.table_size-1, charthick=charthick[ires], $
          alignment=0.5, /device
;
;  For the coronagraphs, overplot the solar position
;
        if (detector eq 'cor1') or (detector eq 'cor2') then begin
            factor = 2.^round(alog(res[ires]/float(header.naxis1))/alog(2.))
            rsun = factor * header.rsun / header.cdelt1
            ntheta = round(2*!pi*rsun)
            theta = 2 * !pi * findgen(ntheta+1) / ntheta
            plots, factor*center[0] + rsun*cos(theta), $
              factor*center[1] + rsun*sin(theta), /device, $
              thick=charthick[ires], color=!d.table_size-1
        endif
;
;  Convert the image to true-color, and write the JPEG file.
;
        true_image = bytarr(3, res[ires], res[ires])
        tvlct, rr, gg, bb, /get
        temp = tvrd()
        true_image[0,*,*] = rr[temp]
        true_image[1,*,*] = gg[temp]
        true_image[2,*,*] = bb[temp]
        write_jpeg, jpeg_file, true_image, true=1, quality=90
;
;  Create a caption for the JPEG file.
;
        ssc_secchi_caption, jpeg_file, header, beacon=beacon
;
;  If not a space weather image, then delete any corresponding space weather
;  images.  Modify the date/time part of the filename for HI images (and some
;  COR2 images).
;
        break_file, jpeg_file, disk0, dir0, name0, ext0
        if strmid(name0, 17, 1) ne '7' then begin
            strput, name0, '?7', 16
            temp = file_search(disk0+dir0+name0+'.*', count=count)
            if count gt 0 then ssc_remove_secchi_beacon, temp else $
              if header.n_images gt 1 then begin
                exthdr = mrdfits(file, 1)
                spwdate = anytim2tai(header.date_cmd) + $
                                     exthdr[header.n_images-1].deltatime
                strput, name0, anytim2cal(spwdate,form=8,/date), 0
                strput, name0, anytim2cal(spwdate,form=8,/time), 9
            endif
            temp = file_search(disk0+dir0+name0+'.*', count=count)
            if count gt 0 then ssc_remove_secchi_beacon, temp
        endif
;
;  Recreate the web pages for the directory.
;
        if not keyword_set(olddir) then ssc_secchi_dir_html, jpeg_path
;
    endif                       ;Modification time earlier than FITS file
endfor                          ;ires
;
end
