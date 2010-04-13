PRO HV_EIT_IMG_TIMERANGE,h,b0,ffhr,s,this_wave,details,dir,fitsname,already_written = already_written, jp2_filename = jp2_filename
;
; Turn the header into a structure
;
  header = fitshead2struct(h)
; Main EIT_IMGE_TIMERANGE code does rebinning, which is not required by the HV project.
; So if a ffhr image was taken undo the rebinning
;
  if ffhr then b0 = rebin(b0,512,512)
;
  header = fitshead2struct(h)
  header = add_tag(header,this_wave,'hv_measurement')
  header = add_tag(header, header.date_obs,'hv_date_obs')
  header = add_tag(header,-header.SC_ROLL,'hv_rotation')
;
; HV - get the components to the observation time and date
;
  yy = strmid(header.date_obs,0,4)
  mm = strmid(header.date_obs,5,2)
  dd = strmid(header.date_obs,8,2)
  hh = strmid(header.date_obs,11,2)
  mmm = strmid(header.date_obs,14,2)
  ss = strmid(header.date_obs,17,2)
  milli = strmid(header.date_obs,20,3)
;
; create the hvs structure and pass it along to JP2Gen
;
  hvs = {dir:dir,$
         fitsname:fitsname,$
         img:b0, $
         header:header,$
         measurement:this_wave,$
         yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli,$
         details:details}

  HV_WRITE_LIST_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written
  if not(already_written) then begin
     HV_LOG_WRITE,hvs,'read ' + s + ' ; ' +HV_JP2GEN_CURRENT(/verbose) + '; at ' + systime(0) + ' : wrote to ' + jp2_filename
  endif
  return
end
