;
; 18 Dec 2009
;
; Return a string array from a text file
;
FUNCTION HV_HVS_READ,filename
  list = readlist(filename)
  return,list
end
