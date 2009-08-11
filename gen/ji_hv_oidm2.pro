;
; Acceptable abbreviations for each observer, and the measurements
; they support
; 
;
FUNCTION JI_HV_OIDM2,name
;
; List of instrument nicknames that are commonly used.  We use the
; nicknames to find out what we require in the Helioviewer System.
; Must be all uppercase.
;
; **********************************************************
; * Edit the "nicknames" array to include a new instrument *
; **********************************************************
  nicknames = ['C2','C3','EIT','MDI']
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
; ZAP
;     If name eq 'ZAP' then begin
;        observatory = 'MAXWELL_C'
;        instrument = 'CONKER'
;        detector = 'ZAP'
;        measurement = ['1600','WL','195','MAG']
;     endif
;
;
;
;
;
;
; LASCO C2
;
     If name eq 'C2' then begin
        observatory = 'SOHO'
        instrument = 'LASCO'
        detector = 'C2'
        measurement = ['orange']
     endif
;
; LASCO C3
;
     if name eq 'C3' then begin
        observatory = 'SOHO'
        instrument = 'LASCO'
        detector = 'C3'
        measurement = ['clear']
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
        measurement = ['continuum','longitudinal-magnetogram']
     endif
  endif
;
; return the answer
;
  return, {nicknames:nicknames, observatory:observatory,instrument:instrument,detector:detector,measurement:measurement}
end
