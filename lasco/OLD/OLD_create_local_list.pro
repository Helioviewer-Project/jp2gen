;
; program to create a local list of files where
; the C2 and C3 data is being stored
;
list_storage = '/Users/ireland/hv/txt/'
root = '/service/soho-archive/soho/private/data/processed/lasco/level_05/'
year = '03'
day_start = 1
day_end = 31
instrument = 'c2'


if (nint(year) le 96) then begin
   yyyy = '20'+year
endif else begin
   yyyy = '19'+year
endelse

for mm = 1,12 do begin
   month =  string(mm,format = '(i02)') 
;
; list the files we want and save them
;
   zz_ntotal = 0.0
   for i = day_start,day_end do begin
      if ( i le 9 ) then begin
         day = '0' + trim(i)
      endif else begin
         day = trim(i)
      endelse
      location = root  + year +  month + day + '/' + instrument + '/'
      store_fits_names = list_storage + year + month + day + '_fits_list_' + instrument + '.txt'
      cmd = 'ls ' + location + '*.fts > ' + store_fits_names
      spawn, cmd
      list = ji_read_txt_list(store_fits_names)
      if (list(0) ne '<zerolengthlist>') then begin
         zz_ntotal = zz_ntotal + n_elements(list)
      endif
   endfor

;
; read the daily lists and concatenate them
;
   zz_list = strarr(zz_ntotal)
   count = 0
   for i =  day_start,day_end do begin
      if ( i le 9 ) then begin
         day = '0' + trim(i)
      endif else begin
         day = trim(i)
      endelse
      location = root  + year +  month + day + '/' + instrument + '/'
      store_fits_names = list_storage + year + month + day + '_fits_list_' + instrument + '.txt'
      list = ji_read_txt_list(store_fits_names)
      if (list(0) ne '<zerolengthlist>') then begin
         nlist = n_elements(list)
         zz_list(count:count+nlist-1) = list(*)
         count = count + nlist
      endif
      spawn,'rm -f ' + store_fits_names
   endfor
   
;
; write the list out as a file
;
   if ( day_start le 9 ) then begin
      dstart = '0' + trim(day_start)
   endif else begin
      dstart = trim(day_start)
   endelse
   if ( day_end le 9 ) then begin
      dend = '0' + trim(day_end)
   endif else begin
      dend = trim(day_end)
   endelse
   filename = list_storage + 'las/' + yyyy + '_' + month + '_' + dstart + 't' + dend + '_' + instrument + '_fits_list.txt'
   print,'Saving to ' + filename
   
   openw,1,filename
   for i = 0,count-1 do begin
      printf,1,zz_list(i)
   endfor
   close,1
endfor   
;
;
;
end
