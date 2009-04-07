;
;
;
filelist = '/Users/ireland/hv/txt/2003_10_mdi_int.txt'

list = ji_read_txt_list(filelist)
n = n_elements(list)

for i = 0,n-1 do begin
   outfile = '/Users/ireland/hv/img/2003/mdi/int/'
   done = ji_mdi_int_write_img(list(i),outfile)
endfor

filelist = '/Users/ireland/hv/txt/2003_10_mdi_mag.txt'

list = ji_read_txt_list(filelist)
n = n_elements(list)

for i = 0,n-1 do begin
   outfile = '/Users/ireland/hv/img/2003/mdi/mag/'
   done = ji_mdi_mag_write_img(list(i),outfile)
endfor





;
;
;
end
