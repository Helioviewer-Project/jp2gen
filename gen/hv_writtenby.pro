;
; 7 April 09
;
; Edit this file to include your institute name and contact details,
; and the location of the Kakadu library
;
FUNCTION HV_WRITTENBY
  return,{local:{institute:'NASA-GSFC',$
                 contact:'Helioviewer Project (webmaster@helioviewer.org)',$
                 kdu_lib_location:'~/KDU/Kakadu/v6_1_1-00781N/bin/Mac-x86-64-gcc/'},$
          transfer:{local:{group:'ireland'},$
                    remote:{user:'ireland',$
                            machine:'helioviewer.nascom.nasa.gov',$
                            incoming:'/home/ireland/incoming2/',$
                            group:'helioviewer'}},$
          webpage:'~/Desktop/'}
END

