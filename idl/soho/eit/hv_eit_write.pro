;
; 16 may 2008
;
; 
;
FUNCTION HV_EIT_WRITE,eit_start,eit_end,rootdir,info
  progname = 'HV_EIT_WRITE'
;
  if (eit_start eq '2012/06/05T00:00:00.000') and (eit_end eq '2012/06/05T23:59:59.000')  then begin
     EIT_IMG_TIMERANGE_4_VENUSTRANSIT,dir_im=rootdir,start=eit_start,end=eit_end,/hv_write,hv_count = hv_count,hv_details = info
endif else begin
  EIT_IMG_TIMERANGE_4,dir_im=rootdir,start=eit_start,end=eit_end,/hv_write,hv_count = hv_count,hv_details = info
endelse
;
;  EIT_IMG_TIMERANGE,dir_im=rootdir,start=eit_start,end=eit_end,/hv_write,hv_count = hv_count,hv_details = info
;
  return,{hv_count:hv_count}
end
