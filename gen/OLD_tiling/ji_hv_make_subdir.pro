PRO ji_hv_make_subdir, told, tnew, observation, outdir, rewrite, time_stamp = time_stamp, datatype_stamp = datatype_stamp
;
; create a new directory if need be
;
  mission = observation.mission
  instrument = observation.instrument
  detector = observation.detector
  measurement = observation.measurement
  new_time_flag = 0
  n = n_elements(outdir)
;
; make a new subdirectory if required
;
  if ((tnew.yy ne told.yy) or $
      (tnew.mm ne told.mm) or $
      (tnew.dd ne told.dd) or $
      (tnew.hh ne told.hh) ) then begin
     for i = 0,n-1 do begin
        spawn,'mkdir ' + outdir(i) + tnew.yy
        spawn,'mkdir ' + outdir(i) + tnew.yy + '/' + tnew.mm
        spawn,'mkdir ' + outdir(i) + tnew.yy + '/' + tnew.mm + '/' + tnew.dd 
        spawn,'mkdir ' + outdir(i) + tnew.yy + '/' + tnew.mm + '/' + tnew.dd + '/' + tnew.hh
     endfor
     told.yy = tnew.yy
     told.mm = tnew.mm
     told.dd = tnew.dd
     told.hh = tnew.hh
     new_time_flag = 1
  endif

  time_stamp =  tnew.yy + '/' + tnew.mm + '/' + tnew.dd + '/' + tnew.hh
  observer = mission + '/' + instrument + '/' + detector

  if (new_time_flag eq 1) then begin
     for i = 0,n-1 do begin
        spawn,'mkdir ' + outdir(i) + time_stamp + '/' + mission
        spawn,'mkdir ' + outdir(i) + time_stamp + '/' + mission + '/'  + instrument
        spawn,'mkdir ' + outdir(i) + time_stamp + '/' + mission + '/'  + instrument + '/' + detector
     endfor
     if (rewrite eq 1) then begin
        for i = 0,n-1 do begin
           pathname = outdir(i) + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement + '/*'
           print,progname + ': Deleting and rewriting tiles at ' + pathname
           spawn,'rm -f ' + pathname
        endfor
     endif else begin
        for i = 0,n-1 do begin
           spawn,'mkdir ' + outdir(i) + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
        endfor
     endelse
     datatype_stamp = observer + '/' + measurement
  endif else begin
     for i = 0,n-1 do begin
        spawn,'mkdir ' + outdir(i) + time_stamp + '/' + mission + '/'  + instrument + '/' + detector + '/' + measurement
     endfor
     datatype_stamp = observer + '/' + measurement
  endelse
  
return
end
