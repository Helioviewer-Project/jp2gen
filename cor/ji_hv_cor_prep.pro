;
; 24 August 2009
;
; ji_hv_euvi_prep
;
; Prep and write jp2 files from STEREO-EUVI data
;

FUNCTION JI_HV_COR_PREP,list,observer
;
; Get the right list
;
  if (observer eq 'COR-A') then begin
     list_sc = list.sc_a
     stereo = 'ahead'
  endif
  if (observer eq 'COR-B') then begin
     list_sc = list.sc_b
     stereo = 'behind'
  endif

;
; Number of elements
;
  n = n_elements(list_sc)
;
; JP2 files written
;
  outfile = strarr(n)
;
; Storage location
;
  storage = JI_HV_STORAGE()


;
; Go through the list
;
  for i = 0,n -1 do begin
;
; Run SECCHI_PREP
;
     JI_SSC_BROWSE_SECCHI_JPEG,list_sc[i],'',stereo,'/service',hv_answer
;
; Get the details of the image
;
     if is_struct(hv_answer) then begin
        img = hv_answer.temp
        header = hv_answer.header
        if header.obsrvtry eq 'STEREO_A'  then begin  
           if header.detector eq 'COR1' then begin
              observer = 'COR1-A'
              rocc_inner = 1.2 ; in units of R_sun, taken from scc_mkmovie.pro
              rocc_outer = 4.0 ; in units of R_sun, taken from scc_mkmovie.pro
           endif
           if header.detector eq 'COR2' then begin 
              observer = 'COR2-A'
              rocc_inner = 2.4 ; in units of R_sun, taken from scc_mkmovie.pro
              rocc_outer = 15.0 ; approximate size of outer radius
           endif
        endif
        if header.obsrvtry eq 'STEREO_B'  then begin
           if header.detector eq 'COR1' then begin
              observer = 'COR1-B'
              rocc_inner = 1.2 ; in units of R_sun, taken from scc_mkmovie.pro
              rocc_outer = 4.0 ; in units of R_sun, taken from scc_mkmovie.pro
           endif
           if header.detector eq 'COR2' then begin
              observer = 'COR2-B'
              rocc_inner = 2.6 ; in units of R_sun, taken from scc_mkmovie.pro
              rocc_outer = 15.0 ; approximate size of outer radius
           endif
        endif
;
; Get the transparency mask
;
; "smask" is the full mask for COR1 and COR2.  These are more accurate
; than simply giving the inner and outer radius of the coronagraphs
;
        smask = get_smask(header)
;
; Load in the HVS observer details
;
        hvs_od = JI_OBSERVER_DETAILS(observer)
;
; HV - set the observation chain
;
        oidm = JI_HV_OIDM2(observer)
        observatory = oidm.observatory
        instrument = oidm.instrument
        detector = oidm.detector
;
; Get the wavelength
;
        measurement = oidm.measurement[0]
;
; Update the FITS header with HV tags
;
        header = add_tag(header,observatory,'hv_observatory')
        header = add_tag(header,instrument,'hv_instrument')
        header = add_tag(header,detector,'hv_detector')
        header = add_tag(header,measurement,'hv_measurement')
        header = add_tag(header, header.date_obs,'hv_date_obs')
        header = add_tag(header, header.crota,'hv_rotation')
        header = add_tag(header, rocc_inner,'hv_rocc_inner')
        header = add_tag(header, rocc_outer,'hv_rocc_outer')
;
; Active Helioviewer tags have a HVA_ to begin with
;
        hd = add_tag(hd,smask,'hva_alpha_transparency')
;
; HV - get the components to the observation time and date
;
        yy = strmid(header.date_obs,0,4)
        mm = strmid(header.date_obs,5,2)
        dd = strmid(header.date_obs,8,2)
        hh = strmid(header.date_obs,11,2)
        mmm = strmid(header.date_obs,14,2)
        ss = strmid(header.date_obs,17,2)
        milli = strmid(header.date_obs,20,3)
;
; create the hvs structure
;
        hvs = {img:img,$
               header:header,$
               observatory:observatory,instrument:instrument,detector:detector,measurement:measurement,$
               yy:yy, mm:mm, dd:dd, hh:hh, mmm:mmm, ss:ss, milli:milli}
;
; write the JP2 file
;
        JI_WRITE_LIST_JP2,hvs,storage.jp2_location, loc = loc,filename = filename
;
;
;
        outfile[i] = loc + filename + '.jp2'
     endif else begin
        outfile[i] = '-1'
     endelse
  endfor
  return, outfile
end
