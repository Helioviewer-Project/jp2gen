;
; Acceptable abbreviations for each observer, and the measurements
; they support
;
;
;
FUNCTION JI_HV_OIDM,name
;
; List of instrument nicknames that are commonly used.  We use the
; nicknames to find out what we require in the Helioviewer System.
; Must be all lowercase.
;
  nickname = strarr(4)
  nickname[0] = 'c2'
  nickname[1] = 'c3'
  nickname[2] = 'eit'
  nickname[3] = 'mdi'
;
; check to see if the name is in the nickname list
;
  inlist = where(strlowcase(name) eq nickname)

  if inlist[0] ne -1 then begin
     case inlist of
;
; LASCO C2
;
        0: observatory = 'SOH'
           instrument = 'LAS'
           detector = '0C2'
           measurement = ['0WL']
;
; LASCO C3
;
        1: observatory = 'SOH'
           instrument = 'LAS'
           detector = '0C3'
           measurement = ['0WL']
;
; EIT
;
        2: observatory = 'SOHO'
           instrument = 'EIT'
           detector = 'EIT'
           measurement = ['304','171','195','284']
;
; MDI
;
        3: observatory = 'SOH'
           instrument = 'MDI'
           detector = 'MDI'
           measurement = ['INT','MAG']
        endcase
;
; return the answer
;
  return, {observatory:observatory,instrument:instrument,detector:detector,measurement:measurement}
end
