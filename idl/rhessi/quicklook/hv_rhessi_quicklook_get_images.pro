
; ROUTINE: HSI_QL_HV_IMAGE
;
; PURPOSE: Creates quicklook RHESSI images for all available energy
; bands for use in Helioviewer
;
; USEAGE: HSI_QL_HV_IMAGE
;
; INPUT: Timerange of interest
;
; OUTPUT: Nothing yet. Plots a RHESSI map for each energy band along
; with an individual FITS header.
;
; KEYWORDS:
;
; AUTHOR: Ryan Milligan (NASA/GSFC) 6-Nov-2013
;             
;-

pro hv_rhessi_quicklook_get_images, timerange, jp2_filename=jp2_filename, already_written=already_written, $
                  overwrite=overwrite, write_contour=write_contour
;
; Are contours to be written also?
;
  if not(keyword_set(write_contour)) then begin
     write_contour = 0
  endif

;
; Program name
;
  progname = 'hv_rhessi_quicklook_get_images'

; Find nearest RHESSI server from which to download QLIMG FITS files
  hsi_server

;; Define timerange
;;  timerange = [ '15-feb-2011 01:00', '15-feb-2011 03:00' ]
;; Array of RHESSI energy bands. QL images are only made up to 300 keV
;; http://www.ssl.berkeley.edu/~jimm/hessi/rhessi_qlook_images.html

; Load in the RHESSI HVS file
  details = HVS_RHESSI_QUICKLOOK()

; get the number of energy bands
  neband = n_elements(details.details)

; get all the energy bands
  eband = fltarr(2, neband)
  for i = 0, neband-1 do begin
     print, details.details[i].eband[*]
     eband[*, i] = details.details[i].eband[*]
  endfor
;  eband = [ [3., 6.], [6., 12.], [12., 25.], [25., 50.], [50.,100.], [100., 300. ] ]

  window, 2, xsize = 800., ysize = 800., retain = 2.
  loadct, 4

; Search the RHESSI flare list for all events within specifed
; timerange. Returns an array of RHESSI flare IDs
  hsi_flare_id = hsi_whichflare(timerange, count=count)
  print, hsi_flare_id, count

; If there are no flares in the time range, return
  if count eq 0 then begin
     print, progname + ': no RHESSI flare in the flare list'
     return
  endif

; At least one flare in the timerange
  for i = 0, count-1 do begin

; Get metadata for each flare
     hsi_flare = hsi_getflare(hsi_flare_id[i])
     print, eband
; Determine number of energy bands in which the flare was observed
     upper_eband = where(reform(eband[1, *]) eq hsi_flare.energy_hi[1])

; Go through all the energy bands up to the maximum
     for j = 0, upper_eband[0] do begin

; Create RHESSI map and corresponding FITS header for each energy
; band. Running this line downloads a QLIMG FITS file of the form
; hsi_qlimg_flareid.fits to the local $HESSI_DATA directory. 
        hsi_map = hsi_qlook_image(flare_id=hsi_flare_id[i],$
                                  /map,$
                                  energy_band=eband[*, j],$
                                  header_out=fits_header,$
                                  filename_out=filename_out)
; Set the comment string
        comment = ''

; Convert to a structure
        header = fitshead2struct(fits_header)

; Break the filepath in to its constituent parts
        break_file, filename_out, disk, dir, name, ext

; Calculate the radius of the Sun in image pixels and add it to the header
        comment = comment + progname + ": added in RSUN FITS header tag. "

; Calculate the distance from the spacecraft to the Sun and add it to
; the header
        comment = comment + progname + ": added in DSUN FITS header tag. "

; Define the image
        image = bytscl(hsi_map.data, /nan)

        dir = disk + dir
        fitsname = name + ext

        ; Get the date information
        time = anytim2utc(header.date_obs, /ext)
;
;  Create the HVS structure.
;
        hvsi = {dir: dir, $
                fitsname: fitsname, $
                header: header, $
                comment: '', $
                measurement: details.details[j].measurement, $
                yy: string(time.year, format='(I4.4)'), $
                mm: string(time.month, format='(I2.2)'), $
                dd: string(time.day, format='(I2.2)'), $
                hh: string(time.hour, format='(I2.2)'), $
                mmm: string(time.minute, format='(I2.2)'), $
                ss: string(time.second, format='(I2.2)'), $
                milli: string(time.millisecond, format='(I3.3)'), $
                details: details}
        hvs = {img: image, hvsi: hvsi}
;
;  Create the JPEG2000 file.
;
        hv_make_jp2, hvs, $
                     jp2_filename=jp2_filename, $
                     already_written=already_written, $
                     overwrite=overwrite
;
; Create contour information
;
        if write_contour eq 1 then begin
           hv_make_contours, hvs, details.contours, $
                             jp2_filename=jp2_filename, $
                             already_written=already_written, $
                             overwrite=overwrite
        endif

    endfor 
  endfor

  return
end


