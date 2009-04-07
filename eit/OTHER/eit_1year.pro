;
;
;
dir_im = '/Users/ireland/hv/img/eit/2003/'

for i = 2,12 do begin
   month =  string(i,format = '(i02)') 
   eit_img_timerange_ji,/sav,start_date = '2003/'+month + '/01', end_date = '2003/'+month + '/31',$
                     dir_im = dir_im + month + '/'

endfor

;
;
;
end
