;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_COR1_PREP2JP2
;
; Purpose     :	Creates COR1 Helioviewer JPEG2000 files
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Converts a STEREO/SECCHI/COR1 Level-0.5 FITS file into JPEG2000
;               format for use by the Helioviewer project
;
; Syntax      :	HV_COR1_PREP2JP2, FILENAME
;
; Examples    :	See HV_COR1_BY_DATE
;
; Inputs      :	FILENAME = The fully qualified FITS filename(s) for an COR1
;                          image.  This can either be a single filename, or a
;                          set of three filenames representing a polarized
;                          brightness sequence of 0,120,240 degrees.
;
;                          As of 22-Dec-2010, all COR1 images should be
;                          polarized brightness sequences.
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
;               BREAK_FILE, ANYTIM2UTC, HV_MAKE_JP2
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 22-Dec-2010, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro hv_cor1_prep2jp2, filename, jp2_filename=jp2_filename, $
                      already_written=already_written, overwrite=overwrite
;
;  Call SECCHI_PREP to prepare the image for display.
;
polariz_on = n_elements(filename) eq 3
secchi_prep, filename, header, image, /calimg_off, /calfac_off, /rotate_on, $
  /smask, polariz_on=polariz_on
;
;  Scale the image.
;
image = bytscl(sqrt(sigrange(image,fraction=.995)), min=0)
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
;  Determine the spacecraft, and get the details structure.
;
case parse_stereo_name(header.obsrvtry, ['a','b']) of
    'a': details = hvs_cor1_a()
    'b': details = hvs_cor1_b()
endcase
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
