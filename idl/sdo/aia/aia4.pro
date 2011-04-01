wave = ['193','211','1600']
wave = ['1600']

for i = 0,n_elements(wave)-1 do begin
   x = 'aia.*'+wave[i] + 'A*lev1.fits'
   list1 = file_list('~/Desktop/AIA_Data/2010-12-01_0000_0001',x)
   list2 = file_list('~/Desktop/AIA_Data/2010-12-01_0001_0002',x)
   list = [list1,list2]
   print,list
   print,' '
   hv_aia_list2jp2_gs2_experimental,list,details_file = 'hvs_version6_aia'
endfor



end
