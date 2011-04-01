;
; 19 Dec 2009
;
; Get the file /gen/hvs.nicknames.oidm.txt and return a structure
; describing the devices and the location of the programs.  this
; program parses the string array returned after reading the data.
;
FUNCTION HV_HVS_GET_NICKNAMES,filename
  list = HV_HVS_READ(filename) ; get the list
  n = n_elements(list)
  ndevice = 0                   ; number of devices
  nstart = [-1]                 ; starting point in the list for each device
  nend = [-1]                   ; end point in the list for each device
  i = -1                        ; counter through the list
  repeat begin
     i = i + 1
     if list[i] eq 'START' then begin
        nstart = [nstart,i]
        j = i
        flag = 0
        repeat begin
           j = j + 1
           if list[j] eq 'END' then flag = flag + 1
           if j eq (n-1) then flag = flag + 10
        endrep until flag ne 0
        if flag eq 10 then begin
           print,'End of file ' + filename + ' with no END statement. Stopping'
           stop
        endif
        nend = [nend,j-1]
        ndevice = ndevice + 1
     endif
  endrep until i eq (n-1)
  nstart = nstart[1:*]
  nend = nend[1:*]
;
  nicknames = strarr[ndevice]
  nicknames_dir = strarr[ndevice]
  for i = 0,ndevice-1 do begin
     v = list[nstart[i],nend[i]]
     
  endfor

  return,struct
end
