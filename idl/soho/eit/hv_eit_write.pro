;
; 16 may 2008
;
; 
;
FUNCTION HV_EIT_WRITE,eit_start,eit_end,rootdir,info
  progname = 'HV_EIT_WRITE'
;
  EIT_IMG_TIMERANGE_4,dir_im=rootdir,start=eit_start,end=eit_end,/hv_write,hv_count = hv_count,hv_details = info
;
;  EIT_IMG_TIMERANGE,dir_im=rootdir,start=eit_start,end=eit_end,/hv_write,hv_count = hv_count,hv_details = info
;
  return,{hv_count:hv_count}
end
