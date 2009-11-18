;
; 7 April 09
;
; Edit this file to include your institute name and contact details,
; and the location of the Kakadu library
;
FUNCTION JI_HV_WRITTENBY
  spawn,'bzr revno ' + getenv("HV_JP2GEN"), out
  if isarray(out) then begin
     bzr_revno = ''
     for i = 0,n_elements(out)-1 do begin
        bzr_revno = bzr_revno + out[i] + '_'
     endfor
  endif else begin
     bzr_revno = out
  endelse
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
