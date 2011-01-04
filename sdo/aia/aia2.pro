
;list = file_list('~/Desktop/AIA_Data/2010-08-02_0000_0010','aia*fits')
;hv_aia_list2jp2_gs,list

list = file_list('~/Desktop/AIA_Data/2010-08-02_0010_0020','aia*fits')
hv_aia_list2jp2_gs2,list,details_file = 'hvs_version4_aia'

list = file_list('~/Desktop/AIA_Data/2010-08-02_0020_0030','aia*fits')
hv_aia_list2jp2_gs2,list,details_file = 'hvs_version3_aia'

;list = file_list('~/Desktop/AIA_Data/2010-08-02-4500','aia*fits')
;hv_aia_list2jp2_gs2,list,details_file = 'hvs_version3_aia'

;list = file_list('~/Desktop/AIA_Data/buggy_maybe','aia*fits')
;hv_aia_list2jp2_gs2,list,details_file = 'hvs_version3_aia'




end
