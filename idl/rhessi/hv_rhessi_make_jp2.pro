;+
; Project: Helioviewer
; 
; Name        : hv_rhessi_make_jp2
;
; Purpose     : Make jp2 files for all images in a single input RHESSI imagecube FITS file
;
; Category    : RHESSI, Helioviewer
;
; Explanation : Each RHESSI imagecube file contains reconstructed images at 
;   multiple times and energies for a single reconstruction algorithm. This routine
;   loops through the times and energies, making jp2 files for each image.
;
; Syntax      : hv_rhessi_make_jp2, file
; 
; Input arguments: 
;   file - Name of RHESSI imagecube fits file (including full path)
;   
; Input keyword arguments:
;   overwrite - if set, replace existing files
;   write_contour - if set make jp2 files of contours (not used currently)
;   
; Output keyword arguments:
;   jp2_files - names of jp2 files written
;   count - number of jp2 files written
;   
; Written: 1-Nov-2021, Kim Tolbert, based on Ryan Milligan's hv_rhessi_quicklook_get_images
; Modifications: 
;   10-Aug-2021, Kim. Made hv_comment a single string instead of array.
;   13-Aug-2021, Kim. Changed current date, and time/energy of image in header to be correct for each image.
;     (Previously just left it as is from imagecube header.)
; 
;-
 
; Notes: 
;   Ryan was skipping if only energy band was 3-6 keV.  I won't have any like that from image archive.
;   Should time in hvsi structure be start of image, or middle? (it's start now)
;
; For testing:
; add_path,'C:\Users\atolbert\working\jp2gen\jp2gen-master\idl',/expand     ;on laptop
; add_path,'/home/softw/jp2gen/jp2gen-master/idl',/expand     ;on hesperia
; f=file_search('C:\Users\atolbert\working\hv_input_files\imagecube_fits','*.fits')
; hv_rhessi_make_jp2, f[0]


pro hv_rhessi_make_jp2, file, $
  overwrite=overwrite, $
  write_contour=write_contour, $
  jp2_files = all_jp2_filenames, $
  count = n_jp2_filenames

  checkvar, write_contour, 0

  call_details = get_calldetails(1)
  progname = call_details.module

  ; Load in the RHESSI HVS file
  details = hvs_rhessi()

  hsi_fits2map, file, maps, /sep
  times = get_uniq(maps.time, count=ntime)
  energies = get_uniq(maps.id, count=nen)

  timerange = minmax(anytim(maps.time))
  flare_id = hsi_whichflare(timerange)
  
  ; alg_short are the alg names that are in the file name
  alg_short = ['_bproj_image_', '_clean_', '_clean59_', '_ge_', '_vis_cs_', '_vf_']
  alg_long = ['Back_Projection', 'Clean', 'Clean59', 'MEM_GE', 'VIS_CS', 'VIS_FWDFIT']
  imatch = -1
  for i=0,5 do if strpos(file,alg_short[i]) ne -1 then imatch = i
  if imatch eq -1 then stop,'Alg not found in name. This should not happen.'
  alg = alg_long[imatch]
  details.detector = alg

  header = headfits(file)
  header = fitshead2struct(header)

  header.naxis = 2
  header = rem_tag(header,['naxis3','naxis4'])

  date_obs = header.date_obs

  ; Re-calculate CRPIX to ensure their values are zero
  header = HV_RECALCULATE_CRPIX(header)
  comment = progname + ": ran HV_RECALCULATE_CRPIX. "

  ; Calculate the radius of the Sun in image pixels and add it to the header
  dummy = get_sun(date_obs, sd=semi_diameter_in_arcsec)
  header = add_tag(header, semi_diameter_in_arcsec / header.cdelt1, 'RSUN')
  comment = comment + progname + ": added in RSUN FITS header tag (units are pixels). "

  ; Calculate the distance from the spacecraft to the Sun and add it to the header
  dummy = get_sun(date_obs, dist=sun_earth_distance_in_au)
  header = add_tag(header, sun_earth_distance_in_au * !CONST.AU, 'DSUN')
  comment = comment + ": added in DSUN FITS header tag (units are meters). "

  ; Push the helioviewer comment into the header - will be extracted later
  header = add_tag(header, comment, 'HV_COMMENT')

  ; Add in the RHESSI flare ID
  header = add_tag(header, flare_id, 'HV_RHESSI_FLARE_ID')
  
  ; Add in the RHESSI image reconstruction method
  header = add_tag(header, alg, 'HV_RHESSI_IMAGE_RECONSTRUCTION_METHOD')

  ;  Create the HVSI structure.
  hvsi = {write_this: 'rhessi', $
    dir: file_dirname(file), $
    fitsname: file_basename(file), $
    header: header, $
    comment: comment, $
    measurement: '', $
    yy: '', $
    mm: '', $
    dd: '', $
    hh: '', $
    mmm: '', $
    ss: '', $
    milli: '', $
    details: details}

  all_jp2_filenames = []

  ; Loop through image energies and times available in input file
  for it = 0,ntime-1 do begin
    for ie = 0,nen-1 do begin
      map = maps[ie,it]

      ;If all elements of image are 0., then skip this time/energy image
      if same_data(minmax(map.data), [0.,0.]) then continue

      energy_band = unformat_intervals(str_replace(map.id,'RHESSI',' '))
      e_index = where(energy_band[0] eq hvsi.details.details.eband[0])

      ; Bytescale the image
      image = bytscl(map.data, /nan)
      
      ; Change header date written to current. And time/energy to this image's values
      head = hvsi.header
      head = rep_tag_value(head, anytim(!stime,/ccsds), 'date')
      head = rep_tag_value(head, double(energy_band[0]), 'energy_l')
      head = rep_tag_value(head, double(energy_band[1]), 'energy_h')
      stime = anytim(map.time)
      etime = stime + map.dur
      head = rep_tag_value(head, anytim(stime,/ccsds), 'date_obs')
      head = rep_tag_value(head, anytim(etime,/ccsds), 'date_end')
      hvsi.header = head

      ; Get the date and time information in external format
      time = anytim2utc(map.time, /ext)

      hvsi.measurement = hvsi.details.details[e_index].measurement
      hvsi.yy = string(time.year, format='(I4.4)')
      hvsi.mm = string(time.month, format='(I2.2)')
      hvsi.dd = string(time.day, format='(I2.2)')
      hvsi.hh = string(time.hour, format='(I2.2)')
      hvsi.mmm = string(time.minute, format='(I2.2)')
      hvsi.ss = string(time.second, format='(I2.2)')
      hvsi.milli = string(time.millisecond, format='(I3.3)')           

      hvs = {img: image, hvsi: hvsi}

      ;  Create the JPEG2000 file.

      hv_make_jp2, hvs, $
        jp2_filename=jp2_filename, $
        already_written=already_written, $
        overwrite=overwrite

      ;If requested, write the contour information.  hmmm... hv_make_contours doesn't exist
      if write_contour eq 1 then begin
        contour_levels = max(hvs.img) * details.fractional_contour_levels
        hv_make_contours, hvs, contour_levels, details.contour_level_names, $
          jp2_filename=jp2_filename, $
          already_written=already_written, $
          overwrite=overwrite
      endif

      all_jp2_filenames = [all_jp2_filenames, jp2_filename]

    endfor
  endfor

  n_jp2_filenames = n_elements(all_jp2_filenames)

end
