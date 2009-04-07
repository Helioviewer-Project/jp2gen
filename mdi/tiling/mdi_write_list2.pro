;
;
;

PRO ji_mdi_write_list2,imglist_root,imglist_root,month,type

  spawn,'mkdir ' +  imglist_root + month
  outfile = imglist_root + month + '/' + type + '/'
  spawn,'mkdir ' +  outfile
  filelist = filelist_root + '_' + month + '_mdi_' + type + '.txt'
  list = ji_read_txt_list(filelist)
  n = n_elements(list)
  for i = 0,n-1 do begin
     done = ji_mdi_int_write_img2(list(i),outfile,/sav)
  endfor

RETURN
END


filelist_root = '/Users/ireland/hv/txt/2003/2003'
imglist_root = '/Users/ireland/hv/img/mdi/2003/'

for j = 1,12 do begin
   month =  string(j,format = '(i02)')  
   ji_mdi_write_list2,imglist_root,imglist_root,month,'int'
   ji_mdi_write_list2,imglist_root,imglist_root,month,'mag'
endfor

;
;
;
end
