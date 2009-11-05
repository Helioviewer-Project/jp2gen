;
; 7 April 09
;
; Edit this file to include your institute name and contact details,
; and the location of the Kakadu library
;
FUNCTION JI_HV_WRITTENBY
  spawn,'bzr revno',bzr_revno
  return,{local:{institute:'NASA-GSFC',$
                 contact:'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)',$
                 kdu_lib_location:'~/KDU/Kakadu/v6_1_1-00781N/bin/Mac-x86-64-gcc/'},$
          source:{institute:'NASA-GSFC',$
                  contact:'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)',$
                  all_code:'https://launchpad.net/helioviewer',$
                  jp2gen_code:'https://launchpad.net/jp2gen',$
                  jp2gen_version:0.5,$
                  jp2gen_branch_revision:bzr_revno}}

END
