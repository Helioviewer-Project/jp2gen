;
; 2nd March 2011
;
; Function to read a Helioviewer Project JPEG2000 file
;
FUNCTION hv_read_jpeg2000,filename,header = header
  ; create a JPEG2000 object
  oJP2 = OBJ_NEW('IDLffJPEG2000',filename)
  ; get the image
  image = oJP2->GetData()
  ; get the XML header
  oJP2->GetProperty,xml = xml
  ; parse the XML - return only a few elements
  header = {naxis1:get_xml_value('NAXIS1'),$
            naxis2:get_xml_value('NAXIS2'),$
            date_obs:get_xml_value('DATE_OBS'),$
            

  return, image
END
