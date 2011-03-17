;
; 2nd March 2011
;
; Function to read a Helioviewer Project JPEG2000 file
;
FUNCTION hv_read_jpeg2000,filename,header = header,map =map
  ; create a JPEG2000 object
  oJP2 = OBJ_NEW('IDLffJPEG2000',filename)
  ; get the image
  data = oJP2->GetData()
  ; get the XML header
  oJP2->GetProperty,xml = xml
  ; parse the XML - return only a few elements
  instrume = get_xml_value(xml,'INSTRUME')
  hv_read_jpeg2000_note = 'Note: a subset of the full FITS file header keywords is returned.'
  if strpos(instrume,'AIA') ne -1 then begin
     header = {hv_read_jpeg2000_note:hv_read_jpeg2000_note,$
               naxis1:nint(get_xml_value(xml,'NAXIS1')),$
               naxis2:nint(get_xml_value(xml,'NAXIS2')),$
               telescop:get_xml_value(xml,'TELESCOP'),$
               instrume:get_xml_value(xml,'INSTRUME'),$
               date_obs:get_xml_value(xml,'DATE_OBS'),$
               t_obs:get_xml_value(xml,'T_OBS'),$
               exptime:double(get_xml_value(xml,'EXPTIME')),$
               wavelnth:get_xml_value(xml,'WAVELNTH'),$
               waveunit:get_xml_value(xml,'WAVEUNIT'),$
               ctype1:get_xml_value(xml,'CTYPE1'),$
               cunit1:get_xml_value(xml,'CUNIT1'),$
               crval1:double(get_xml_value(xml,'CRVAL1')),$
               cdelt1:double(get_xml_value(xml,'CDELT1')),$
               crpix1:double(get_xml_value(xml,'CRPIX1')),$
               ctype2:get_xml_value(xml,'CTYPE2'),$
               cunit2:get_xml_value(xml,'CUNIT2'),$
               crval2:double(get_xml_value(xml,'CRVAL2')),$
               cdelt2:double(get_xml_value(xml,'CDELT2')),$
               crpix2:double(get_xml_value(xml,'CRPIX2')),$
               r_sun:double(get_xml_value(xml,'R_SUN'))}
  endif
  if strpos(instrume,'HMI') ne -1 then begin
     header = {hv_read_jpeg2000_note:hv_read_jpeg2000_note,$
               naxis1:nint(get_xml_value(xml,'NAXIS1')),$
               naxis2:nint(get_xml_value(xml,'NAXIS2')),$
               telescop:get_xml_value(xml,'TELESCOP'),$
               instrume:get_xml_value(xml,'INSTRUME'),$
               date_obs:get_xml_value(xml,'DATE_OBS'),$
               t_obs:get_xml_value(xml,'T_OBS'),$
               ;exptime:double(get_xml_value(xml,'EXPTIME')),$
               wavelnth:get_xml_value(xml,'WAVELNTH'),$
               ;waveunit:get_xml_value(xml,'WAVEUNIT'),$
               content:get_xml_value(xml,'CONTENT'),$
               ctype1:get_xml_value(xml,'CTYPE1'),$
               cunit1:get_xml_value(xml,'CUNIT1'),$
               crval1:double(get_xml_value(xml,'CRVAL1')),$
               cdelt1:double(get_xml_value(xml,'CDELT1')),$
               crpix1:double(get_xml_value(xml,'CRPIX1')),$
               ctype2:get_xml_value(xml,'CTYPE2'),$
               cunit2:get_xml_value(xml,'CUNIT2'),$
               crval2:double(get_xml_value(xml,'CRVAL2')),$
               cdelt2:double(get_xml_value(xml,'CDELT2')),$
               crpix2:double(get_xml_value(xml,'CRPIX2')),$
               rsun_obs:double(get_xml_value(xml,'RSUN_OBS'))}
  endif

  output = data
  if keyword_set(map) then begin
     index2map,header,data,map
     output = map
  endif

  return, output
END
