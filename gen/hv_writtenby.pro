;
; 7 April 09
;
; Edit this file to include your institute name and contact details,
; and the location of the Kakadu library
;
FUNCTION HV_WRITTENBY
  loc = getenv("HV_JP2GEN")
  bzr_revno = HV_BZR_REVNO_HANDLER(loc)
  return,{local:{institute:'NASA-GSFC',$
                 contact:'Helioviewer Project (webmaster@helioviewer.org)',$
                 kdu_lib_location:'~/KDU/Kakadu/v6_1_1-00781N/bin/Mac-x86-64-gcc/'},$
          source:{institute:'NASA-GSFC',$
                  contact:'Part of the Helioviewer Project as funded by ESA and NASA.  Contact the Helioviewer Project at webmaster@helioviewer.org',$
                  all_code:'https://launchpad.net/helioviewer',$
                  jp2gen_code:'https://launchpad.net/jp2gen',$
                  jp2gen_version:0.8,$
                  jp2gen_branch_revision:bzr_revno}}

END
