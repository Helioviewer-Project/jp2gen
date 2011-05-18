;
; 1 October 2010
;
; Function to convert the time of an HV filename to a CCSDS time.
;
; TODO - add check that a Helioviewer filename has been passed
;
FUNCTION HV_HV2CCSDS,filename
  z = STRSPLIT(filename,'__',/extract)
;
  ccsds = z[0] + '-' + $
          z[1] + '-' + $
          z[2] + 'T' + $
          z[3] + ':' + $
          z[4] + ':' + $
          z[5] + '.' + $
          z[6] + 'Z'

  return,ccsds
end
