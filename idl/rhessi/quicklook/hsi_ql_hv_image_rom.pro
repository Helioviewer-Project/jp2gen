
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

pro hsi_ql_hv_image;, timerange

;; Find nearest RHESSI server from which to download QLIMG FITS files
  hsi_server
;; Define timerange
  timerange = [ '15-feb-2011 01:00', '15-feb-2011 03:00' ]
;; Array of RHESSI energy bands. QL images are only made up to 300 keV
;; http://www.ssl.berkeley.edu/~jimm/hessi/rhessi_qlook_images.html
  eband = [ [3., 6.], [6., 12.], [12., 25.], [25., 50.], [50.,100.], [100., 300. ] ]

  window, 2, xsize = 800., ysize = 800., retain = 2.
  loadct, 4

;; Search the RHESSI flare list for all events within specifed
;; timerange. Returns an array of RHESSI flare IDs
  hsi_flare_id = hsi_whichflare( timerange, count = count )
  for i = 0, count-1 do begin
;; Get metadata for each flare
    hsi_flare = hsi_getflare( hsi_flare_id[ i ] )
;; Determine number of energy bands in which the flare was observed
    upper_eband = where( reform( eband[ 1, * ] ) eq hsi_flare.energy_hi[ 1 ] )
    for j = 0, upper_eband[ 0 ] do begin
;; Create RHESSI map and corresponding FITS header for each energy
;; band. Running this line downloads a QLIMG FITS file of the form
;; hsi_qlimg_flareid.fits to the local $HESSI_DATA directory. 
    hsi_map = hsi_qlook_image( flare_id = hsi_flare_id[ i ], /map, energy_band = eband[ *, j ], header_out = fits_header )
;; Plot RHESSI map with 50% and 80% contour overlaid.=
    plot_map, hsi_map
    plot_map, hsi_map, /over, level = [ 0.5, 0.8 ]*max( hsi_map.data ), thick = 2., color = 0
    endfor 
  endfor

end


