;+
; Project     :	STEREO - SECCHI
;
; Name        :	HV_EUVI_PREP2JP2
;
; Purpose     :	Creates EUVI Helioviewer JPEG2000 files
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Converts a STEREO/SECCHI/EUVI Level-0.5 FITS file into JPEG2000
;               format for use by the Helioviewer project
;
; Syntax      :	HV_EUVI_PREP2JP2, FILENAME
;
; Examples    :	
;
; Inputs      :	FILENAME = The fully qualified FITS filename for an EUVI image
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
; Calls       :	SECCHI_PREP, SCC_BYTSCL, SECCHI_COLORS, FITSHEAD2WCS,
;               WCS_GET_PIXEL, PARSE_STEREO_NAME, BREAK_FILE, NTRIM,
;               ANYTIM2UTC, HV_MAKE_JP2
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
pro hv_euvi_prep2jp2, filename, jp2_filename=jp2_filename, $
                      already_written=already_written, overwrite=overwrite
;
;  Call SECCHI_PREP to prepare the image for display.
;
secchi_prep, filename, header, image, /calimg_off, /rotate_on
;
;  Scale the image.
;
image = scc_bytscl(image, header)
;
;  Pass through the color table, and convert to greyscale.
;
secchi_colors, 'euvi', header.wavelnth, red, green, blue
image = round(0.3*red[image] + 0.59*green[image] + 0.11*blue[image]) 
;
;  Make sure that the CRVAL* values are zero.
;
if (header.crval1 ne 0) or (header.crval2 ne 0) then begin
    wcs = fitshead2wcs(header)
    center = wcs_get_pixel(wcs, [0,0])
    header.crpix1 = center[0]
    header.crpix2 = center[1]
    header.crval1 = 0
    header.crval2 = 0
endif
;
;  Determine the spacecraft, and get the details structure.
;
case parse_stereo_name(header.obsrvtry, ['a','b']) of
    'a': details = hvs_euvi_a()
    'b': details = hvs_euvi_b()
endcase
;
;  Create the HVS structure.
;
break_file, filename, disk, dir, name, ext
dir = disk + dir
fitsname = name + ext
measurement = ntrim(header.wavelnth)
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
