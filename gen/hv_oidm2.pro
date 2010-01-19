;
; Acceptable abbreviations for each observer, and the measurements
; they support
; 
;
FUNCTION HV_OIDM2,name
;
; List of instrument nicknames that are commonly used.  We use the
; nicknames to find out what we require in the Helioviewer System.
; Must be all uppercase.
;
; **********************************************************
; * Edit the "nicknames" array to include a new observer *
; **********************************************************
  nicknames = ['LASCO-C2','LASCO-C3','EIT','MDI',$ ; SOHO
               'EUVI-A','COR1-A','COR2-A',$ ; STEREO-A
               'EUVI-B','COR1-B','COR2-B'] ; STEREO-B
;
;
;
  name = strupcase(name)
;
; check to see if the input name is in the nickname list
;
  inlist = where(nicknames eq name)
  if inlist[0] ne -1 then begin
; **********************************************************
; * Include the description of the new instrument below *
; **********************************************************
; 
; See the wiki page 
; http://www.helioviewer.org/wiki/index.php?title=Converting_FITS_to_JP2_for_the_Helioviewer_Project
; for more details
;
; ZAP-C
;     If name eq 'ZAP-C' then begin
;        observatory = 'MAXWELL-C'
;        instrument = 'CONKER'
;        detector = 'ZAP'
;        measurement = ['1600','WL','195','polarity']
;     endif
;
;
;
;
;
;
; LASCO C2
;
     If name eq 'LASCO-C2' then begin
        observatory = 'SOHO'
        instrument = 'LASCO'
        detector = 'C2'
        measurement = ['white-light']
     endif
;
; LASCO C3
;
     if name eq 'LASCO-C3' then begin
        observatory = 'SOHO'
        instrument = 'LASCO'
        detector = 'C3'
        measurement = ['white-light']
     endif
;
; EIT
;
     if name eq 'EIT' then begin
        observatory = 'SOHO'
        instrument = 'EIT'
        detector = 'EIT'
        measurement = ['304','171','195','284']
     endif
;
; MDI
;
     if name eq 'MDI' then begin
        observatory = 'SOHO'
        instrument = 'MDI'
        detector = 'MDI'
        measurement = ['continuum','magnetogram']
     endif
;
; EUVI-A
;
     if name eq 'EUVI-A' then begin
        observatory = 'STEREO-A'
        instrument = 'SECCHI'
        detector = 'EUVI'
        measurement = ['304','171','195','284']
     endif
;
; COR1-A
;
     if name eq 'COR1-A' then begin
        observatory = 'STEREO-A'
        instrument = 'SECCHI'
        detector = 'COR1'
        measurement = ['white-light']
     endif
;
; COR2-A
;
     if name eq 'COR2-A' then begin
        observatory = 'STEREO-A'
        instrument = 'SECCHI'
        detector = 'COR2'
        measurement = ['white-light']
     endif
;
; EUVI-B
;
     if name eq 'EUVI-B' then begin
        observatory = 'STEREO-B'
        instrument = 'SECCHI'
        detector = 'EUVI'
        measurement = ['304','171','195','284']
     endif
;
; COR1-B
;
     if name eq 'COR1-B' then begin
        observatory = 'STEREO-B'
        instrument = 'SECCHI'
        detector = 'COR1'
        measurement = ['white-light']
     endif
;
; COR2-B
;
     if name eq 'COR2-B' then begin
        observatory = 'STEREO-B'
        instrument = 'SECCHI'
        detector = 'COR2'
        measurement = ['white-light']
     endif

  endif
;
; return the answer
;
  return, {nicknames:nicknames, observatory:observatory,instrument:instrument,detector:detector,measurement:measurement}
end
