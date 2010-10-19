
;list = file_list('~/Desktop/AIA_Data/2010-08-02_0000_0010','aia*fits')
;hv_aia_list2jp2_gs,list

;list = file_list('~/Desktop/AIA_Data/2010-08-02_0010_0020','aia*fits')
;hv_aia_list2jp2_gs2,list,details_file = 'hvs_version2_aia'

;list = file_list('~/Desktop/AIA_Data/2010-08-02-4500','aia*fits')
;hv_aia_list2jp2_gs2,list,details_file = 'hvs_version3_aia'

list = file_list('~/Desktop/AIA_Data/hmi','hmi*ma*fits')
hv_hmi_list2jp2_gs,list,details_file = 'hvs_default_hmi'

list = file_list('~/Desktop/AIA_Data/hmi','hmi*con*fits')
hv_hmi_list2jp2_gs,list,details_file = 'hvs_default_hmi'




end
