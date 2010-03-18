FUNCTION HV_MDI_PREP2JP2_EACH,mdidir,search_term,ds,de,storage,int = int,mag = mag, info = info
  progname = 'HV_MDI_PREP2JP2_EACH'
;
; Get file list
;
  a = HV_MDI_GET_LIST(mdidir,search_term, ds,de)
  date_start = a.date_start
  date_end = a.date_end
  list = a.list
  print,progname + ': Closest time to requested start date = ' + date_start
  print,progname + ': Closest time to requested end date   = ' + date_end
;
; Write direct to JP2 from FITS
;
  output = HV_MDI_WRITE_HVS(list,storage.jp2_location,int = int,mag = mag, details= info)
  return,output
end
