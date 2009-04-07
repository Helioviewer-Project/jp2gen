;
;
;
PRO ji_write_jp2, image, red, green, blue, observer, measurement, out_dir = out_dir, stamp = stamp

  IF (observer eq 'soho/EIT/EIT') then begin
     bitrate_jp2 = [0.3,0.01]
     n_layers_jp2 = 8
     n_levels_jp2 = 8

     fstr= out_dir +'/' + stamp + '.jp2'
     oJP2 = OBJ_NEW('IDLffJPEG2000',fstr,/WRITE,BIT_RATE=bitrate_jp2,n_layers=n_layers_jp2,n_levels=n_levels_jp2,bit_depth=8)
     oJP2->SetData,image
     OBJ_DESTROY, oJP2
  ENDIF


  IF (observer eq 'soho/LAS/0C2') then begin
     bitrate_jp2 = [0.3,0.01]
     n_layers_jp2 = 8
     n_levels_jp2 = 8

     fstr= out_dir +'/' + stamp + '.jp2'
     oJP2 = OBJ_NEW('IDLffJPEG2000',fstr,/WRITE,BIT_RATE=bitrate_jp2,n_layers=n_layers_jp2,n_levels=n_levels_jp2,bit_depth=8)
     oJP2->SetData,image
     OBJ_DESTROY, oJP2
  ENDIF


  IF (observer eq 'soho/MDI/MDI') then begin
     bitrate_jp2 = [0.3,0.01]
     n_layers_jp2 = 8
     n_levels_jp2 = 8

     fstr= out_dir +'/' + stamp + '.jp2'
     oJP2 = OBJ_NEW('IDLffJPEG2000',fstr,/WRITE,BIT_RATE=bitrate_jp2,n_layers=n_layers_jp2,n_levels=n_levels_jp2,bit_depth=8)
     oJP2->SetData,image
     OBJ_DESTROY, oJP2
  ENDIF


return
end
