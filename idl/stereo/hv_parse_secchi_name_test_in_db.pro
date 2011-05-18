;
;
;
FUNCTION HV_PARSE_SECCHI_NAME_TEST_IN_DB,filename
;
  if n_elements(filename) eq 3 then begin
     fname = filename[0]
  endif else begin
     fname = filename
  endelse
  break_file, fname, disk, dir, name, ext
;
  bits = strsplit(name,'_',/extract)
  date = bits[0]
  yy = strmid(date,0,4)
  mm = strmid(date,4,2)
  dd = strmid(date,6,2)
  inst = strmid(bits[2],2,2)
  spc = strmid(bits[2],4,1)
;
  dummy = readfits(fname,hd)
  header = fitshead2struct(hd)

  if spc eq 'A' then begin
     if inst eq 'c1' then begin
        details = HVS_COR1_A()
        measurement='white-light'
     endif
     if inst eq 'c2' then begin
        details = HVS_COR2_A()
        measurement='white-light'
     endif
     if inst eq 'eu' then begin
        details = HVS_EUVI_A()
        measurement = trim(header.wavelnth)
     endif

  endif
  if spc eq 'B' then begin
     if inst eq 'c1' then begin
        details = HVS_COR1_B()
        measurement='white-light'
     endif
     if inst eq 'c2' then begin
        details = HVS_COR2_B()
        measurement='white-light'
     endif
     if inst eq 'eu' then begin
        details = HVS_EUVI_B()
        measurement = trim(header.wavelnth)
     endif
  endif



  hvsi = {yy:yy,$
          mm:mm,$
          dd:dd,$
          fitsname:name+ext,$
          measurement:measurement,$
          details:details,$
          header:header}

  HV_DB,hvsi,/check_fitsname_only,already_written = already_written
  return,already_written
end
