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
  sohoRotAngle = header.SC_ROLL ; get the roll angle
  header = add_tag(header,this_wave,'hv_measurement')
  header = add_tag(header, header.date_obs,'hv_date_obs')
  header = add_tag(header,sohoRotAngle,'hv_rotation')
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
;___from J. Ireland (2010-11-08):
; Rotate the image to take care of the new orientation of SOHO
;
  if (sohoRotAngle eq 180) then begin
     b0 = rotate(b0,2)
  endif else begin
     if (sohoRotAngle ne 0) then begin
        b0[0:5,*] = 0.0 ; zero the edges in an attempt to cut out on artifacts at the edge that can appear after peforming a roll which is not a multiple of 90 degrees.
        b0[1018:1023,*] = 0.0
        b0[*,0:5] = 0.0
        b0[*,1018:1023] = 0.0
        b0 = rot(b0,sohoRotAngle,1.0,header.crpix1,header.crpix2,/pivot,/interp,missing = 0.0)
        ;print,'********************',header.crpix1,header.crpix2
        ;pivotCenter = [header.crpix1,header.crpix2]
        ;pivotCenter = [511.5,511.5]
        ;b0 = HV_MOVE_IMAGE(b0,header.crpix1,header.crpix2)
        ;header = add_tag(header,header.crpix1,'hv_crpix1_original')     ; keep a store of the original sun centre
        ;header = add_tag(header,header.crpix2,'hv_crpix2_original')
        ;header.crpix1 = 511.5
        ;header.crpix2 = 511.5

        ;b0 = rot(b0,sohoRotAngle,1.0,pivotCenter[0],pivotCenter[1],/pivot,/interp,missing = 0.0) ; IDL says the images are rotated clockwise
        ;header = add_tag(header,header.crpix1,'hv_crpix1_original')     ; keep a store of the original sun centre
        ;header = add_tag(header,header.crpix2,'hv_crpix2_original')
        ;rotatedSolarCentre = HV_CALC_ROT_CENTRE( [header.crpix1,header.crpix2], sohoRotAngle, [511.5, 511.5] ) ; calculate the new solar centre given that we have performed a clockwise rotation on the original image
        ;b0 = HV_MOVE_IMAGE(b0,rotatedSolarCentre[0],rotatedSolarCentre[1])
        ;header.crpix1 = rotatedSolarCentre[0]
        ;header.crpix2 = rotatedSolarCentre[1]
     endif
  endelse

;
; create the hvs structure and pass it along to JP2Gen
;
  hvsi = {dir:dir,$
          fitsname:fitsname,$
          header:header,$
          comment:'',$
          yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli,$
          measurement:this_wave,$
          details:details}

  hvs = {img:b0,hvsi:hvsi}

  HV_MAKE_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written

;  HV_WRITE_LIST_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written
;  if not(already_written) then begin
;     HV_LOG_WRITE,hvs.hvsi,'read ' + s + ' ; ' +HV_JP2GEN_CURRENT(/verbose) + '; at ' + systime(0) + ' : wrote to ' + jp2_filename
;  endif
  return
end
