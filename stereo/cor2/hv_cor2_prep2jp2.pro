;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_COR2_PREP2JP2
;
; Purpose     :	Creates COR2 Helioviewer JPEG2000 files
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Converts a STEREO/SECCHI/COR2 Level-0.5 FITS file into JPEG2000
;               format for use by the Helioviewer project
;
; Syntax      :	HV_COR2_PREP2JP2, FILENAME
;
; Examples    :	
;
; Inputs      :	FILENAME = The fully qualified FITS filename(s) for an COR2
;                          image.  This can either be a single filename for a
;                          double exposure image, or a set of three filenames
;                          representing a polarized brightness sequence of
;                          0,120,240 degrees.
;
; Opt. Inputs :	None.
;
; Outputs     :	Creates the JPEG2000 file, plus associated files
;
; Opt. Outputs:	None.
;
; Keywords    :	OVERWRITE = If set, then write the file even if already present
;
;               JP2_FILENAME = Returns the full path and filename of the
;                              JPEG2000 file written
;
;               ALREADY_WRITTEN = Returns a Boolean variable describing if the
;                                 file was already written or not
;
; Calls       :	SECCHI_PREP, FITSHEAD2WCS, WCS_GET_PIXEL, PARSE_STEREO_NAME,
;               BREAK_FILE, ANYTIM2UTC, HV_MAKE_JP2, SCC_GETBKGIMG,
;               SCC_ROLL_IMAGE
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If no background image is found, then the program returns
;               without creating a JPEG2000 image.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 22-Dec-2010, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro hv_cor2_prep2jp2, filename, jp2_filename=jp2_filename, $
                      already_written=already_written, overwrite=overwrite
;
;  Call SECCHI_PREP to prepare the image for display.
;
polariz_on = n_elements(filename) eq 3
secchi_prep, filename, header, image, /calimg_off, /calfac_off, /smask, $
  polariz_on=polariz_on
;
;  Determine the spacecraft, and get the details structure.
;
sc = parse_stereo_name(header.obsrvtry, ['a','b'])
case sc of
    'a': details = hvs_cor2_a()
    'b': details = hvs_cor2_b()
endcase
;
;  Define the relative min and max values.  These get modified depending on
;  the spacecraft and kind of image.
;
amin = 0.95
amax = 1.15
if sc eq 'b' then begin
    amin = 0.975
    amax = 1.11250
endif
;
;  Correct double exposure images for the non-linearity effect.
;
if ~polariz_on then begin
    a0 = 1.04418
    a1 = -0.00645004
    scl = (a0 + a1*alog(header.exptime)) + a1*alog(image>1)
    image = image / (scl > 1)
endif
;
;  Get the background image and divide it.  For Behind images before March 8,
;  2007, do a subtraction instead, and use a different range.
;
bkg = scc_getbkgimg(header, /totalb)
if n_elements(bkg) le 1 then return                     ;no background
nmedian = 5
if (sc eq 'b') and (header.date_obs lt '2007-03-08') then begin
    image = median(image - bkg, nmedian)
    amin = -10
    amax = 100
end else image = median(image / bkg, nmedian)
;
;  Rotate the image.
;
scc_roll_image, header, image
;
;  Scale the image.
;
image = bytscl(image, min=amin, max=amax, /nan)
;
;  Recalculate CRPIX* so that the CRVAL* values are zero.
;
wcs = fitshead2wcs(header)
center = wcs_get_pixel(wcs, [0,0])
header.crpix1 = center[0]
header.crpix2 = center[1]
header.crval1 = 0
header.crval2 = 0
;
;  Create the HVS structure.  For polarization sequences, the filename used is
;  the first in the series.
;
break_file, filename[0], disk, dir, name, ext
dir = disk + dir
fitsname = name + ext
measurement = 'white-light'
ext = anytim2utc(header.date_obs, /ext)
hvsi = {dir: dir, $
        fitsname: fitsname, $
        header: header, $
        comment: '', $
        measurement: measurement, $
        yy: string(ext.year, format='(I4.4)'), $
        mm: string(ext.month, format='(I2.2)'), $
        dd: string(ext.day, format='(I2.2)'), $
        hh: string(ext.hour, format='(I2.2)'), $
        mmm: string(ext.minute, format='(I2.2)'), $
        ss: string(ext.second, format='(I2.2)'), $
        milli: string(ext.millisecond, format='(I3.3)'), $
        details: details}
hvs = {img: image, hvsi: hvsi}
;
;  Create the JPEG2000 file.
;
hv_make_jp2, hvs, jp2_filename=jp2_filename, already_written=already_written, $
  overwrite=overwrite
;
end
