;
; 24 September 2010
;
; Conversion of HMI data to JPEG2000 files for use with the
; Helioviewer Project
;
;
;
PRO hv_hmi_list2jp2_gs,list,$
                    details_file = details_file,$ ; HMI details file
                    copy2outgoing = copy2outgoing,$ ; Copy the files to an outgoing directory
                    called_by = called_by,$ ; calling program (if any)
                    transfer_direct = transfer_direct ; transfer JP2 files from local to remote direct from original JP2 archive.
  progname = 'hv_hmi_list2jp2_gs'
;
; Line feed character:
;
  lf=string(10b)
;
; start time
;
  t0 = systime(1)
;
; use the default HMI file is no other one is specified
;
  if not(keyword_set(details_file)) then begin
     info = CALL_FUNCTION('hvs_default_hmi')
  endif else begin
     info = CALL_FUNCTION(details_file)
  endelse
  nickname = info.nickname
;
; Storage
;
  storage = HV_STORAGE(nickname = info.nickname)
;
; get general information
;
  g = HVS_GEN()
;
; Get contact details
;
  wby = HV_WRITTENBY()
;
; If called_by information is given, pass it along.  Otherwise, just
; use this program name
;
;  if keyword_set(called_by) then begin
;     info = add_tag(info,called_by,'called_by')
;  endif else begin
;     info = add_tag(info,progname,'called_by')
;  endelse
;
; All the supported measurements
;
  wave_arr = info.details[*].measurement
;
; Number of elements in the list
;
  nl = n_elements(list)
  prepped = strarr(nl)
;
; Get the fitsnames
;
  for ii = 0,nl-1 do begin
     fullname = list[ii]         ; get the full directory and filename
     z = strsplit(fullname,path_sep(),/extract) ; split up to get filename
     nz = n_elements(z)
     fitsname = z[nz-1]
     img = readfits(fullname,hd)   ; get image and data
     hd = fitshead2struct(hd)
;
; This string will describe what is done to the data
;
     hv_img_function = 'Two-dimensional image data IMG'
;
; Check that this FITS file is supported
;
     flag = 0
     if trim(hd.content) eq 'MAGNETOGRAM' then begin
        measurement = 'magnetogram'
        flag = 1
     endif
     if trim(hd.content) eq 'CONTINUUM INTENSITY' then begin
        measurement = 'continuum'
        flag = 1
     endif
;
; If supported, then go ahead
;
     if flag eq 1 then begin
        this_wave = where(wave_arr eq measurement,this_wave_count)
;
; Trim the limb of the magnetogram
;
        if measurement eq 'magnetogram' then begin
           rrr = hd.RSUN_OBS/hd.CDELT1
           ss2 = circle_mask(img, hd.CRPIX1, hd.CRPIX2, 'GE', rrr )
           if (ss2(0) ne -1) then img(ss2)=-300000.0
           hv_img_function = hv_img_function + ' : SS2 = CIRCLE_MASK(IMG, HD.CRPIX1, HD.CRPIX2, "GE", HD.RSUN_OBS/HD.CDELT1 ) : IF (SS2(0) NE -1) THEN IMG(SS2)=-300000.0'
        endif
;
; Construct an HVS
;
        dmin = info.details[this_wave].dataMin
        dmax = info.details[this_wave].dataMax
        dminString = trim(dmin)
        dmaxString = trim(dmax)

        tobs = HV_PARSE_CCSDS(hd.date_obs)
        img = (img > (dmin)) < dmax

        if info.details[this_wave].dataScalingType eq 0 then begin
           img = bytscl(img,/nan)
           hv_img_function = hv_img_function + ' : IMG = BYTSCL(IMG,/NAN)'
        endif
        if info.details[this_wave].dataScalingType eq 1 then begin
           img = bytscl(sqrt(img),/nan)
           hv_img_function = hv_img_function + ' : IMG = BYTSCL(SQRT(IMG),/NAN)'
        endif
        if info.details[this_wave].dataScalingType eq 3 then begin
           img = bytscl(alog10(img),/nan)
           hv_img_function = hv_img_function + ': IMG = BYTSCL(ALOG10(IMG),/NAN)'
        endif
        hd = add_tag(hd,info.observatory,'hv_observatory')
        hd = add_tag(hd,info.instrument,'hv_instrument')
        hd = add_tag(hd,info.detector,'hv_detector')
        hd = add_tag(hd,measurement,'hv_measurement')
        hd = add_tag(hd,0.0,'hv_rotation')
        hd = add_tag(hd,progname,'hv_source_program')
;
; Create the hvs structure
;
        hvsi = {dir:'',$
                fitsname:fitsname,$
                header:hd,$
                yy:tobs.yy,$
                mm:tobs.mm,$
                dd:tobs.dd,$
                hh:tobs.hh,$
                mmm:tobs.mmm,$
                ss:tobs.ss,$
                milli:tobs.milli,$
                measurement:measurement,$
                details:info}
        hvs = {img:img,hvsi:hvsi}

        already_written = 0
;     HV_WRITE_LIST_JP2,hvs, jp2_filename = jp2_filename, already_written = already_written
;
; Make the storage directory
;
        loc = storage.jp2_location + (HV_DIRECTORY_CONVENTION(hvsi.yy,hvsi.mm,hvsi.dd,hvsi.measurement))[3]

        if not(is_dir(loc)) then spawn,'mkdir -p '+ loc
;
; File name convention
;
        date =hvsi. yy + '_' +  hvsi.mm + '_' +  hvsi.dd
        time =  hvsi.hh + '_' +  hvsi.mmm + '_' +   hvsi.ss + '_' +  hvsi.milli
;     observer =  observatory + '_' +  instrument + '_' +  detector
        observation = 'SDO_HMI_HMI' + '_' +  measurement
        jp2_filename = date + '__' + time + '__' + observation + '.jp2'
;
; Write the file
;
;     HV_WRITE_JP2_LWG,loc + jp2_filename,img,fitsheader = hd,details = info,measurement = measurement
;
; Who created this file and where
;
        hv_comment = 'JP2 file created locally at ' + wby.local.institute + $
                     ' using '+ progname + $
                     ' at ' + systime() + '.' + lf + $
                     'Contact ' + wby.local.contact + $
                     ' for more details/questions/comments regarding this JP2 file.'+lf
;
; Which setup file was used
;
        hv_comment = hv_comment + 'HVS (Helioviewer setup) file used to create this JP2 file: ' + $
                     info.hvs_details_filename + ' (version ' + info.hvs_details_filename_version + ').'+lf
;
; Source code attribution
;
        hv_comment = HV_XML_COMPLIANCE(hv_comment + $
                                       'FITS to JP2 source code provided by ' + g.source.contact + $
                                       '[' + g.source.institute + ']'+ $
                                       ' and is available for download at ' + g.source.jp2gen_code + '.' + lf + $
                                       'Please contact the source code providers if you suspect an error in the source code.' + lf + $
                                       'Full source code for the entire Helioviewer Project can be found at ' + g.source.all_code + '.')
        if tag_exist(hd,'hv_comment') then begin
           hv_comment = HV_XML_COMPLIANCE(hd.hv_comment) + lf + hv_comment
        endif
;
; ********************************************************************************************************
;
; Write the XML tags
;
;
;  FITS header into string in XML format:  
;
        xh = ''
        ntags = n_tags(hd)
        tagnames = tag_names(hd) 
        tagnames = HV_XML_COMPLIANCE(tagnames)
        jcomm = where(tagnames eq 'COMMENT')
        jhist = where(tagnames eq 'HISTORY')
        jhv = where(strupcase(strmid(tagnames[*],0,3)) eq 'HV_')
        jhva = where(strupcase(strmid(tagnames[*],0,4)) eq 'HVA_')
        indf1=where(tagnames eq 'TIME_D$OBS',ni1)
        if ni1 eq 1 then tagnames[indf1]='TIME-OBS'
        indf2=where(tagnames eq 'DATE_D$OBS',ni2)
        if ni2 eq 1 then tagnames[indf2]='DATE-OBS'     
        xh='<?xml version="1.0" encoding="UTF-8"?>'+lf
;
; Enclose all the FITS keywords in their own container
; 
        xh+='<meta>'+lf
;
; FITS keywords
;
        xh+='<fits>'+lf
        for j=0,ntags-1 do begin
           if ( (where(j eq jcomm) eq -1) and $
                (where(j eq jhist) eq -1) and $
                (where(j eq jhv) eq -1)   and $
                (where(j eq jhva) eq -1) )then begin      
;            xh+='<'+tagnames[j]+' descr="">'+strtrim(string(header.(j)),2)+'</'+tagnames[j]+'>'+lf
              value = HV_XML_COMPLIANCE(strtrim(string(hd.(j)),2))
              xh+='<'+tagnames[j]+'>'+value+'</'+tagnames[j]+'>'+lf
           endif
        endfor
;
; FITS history
;
        xh+='<history>'+lf
        j=jhist
        k=0
        while (hd.(j))[k] ne '' do begin
           value = HV_XML_COMPLIANCE((hd.(j))[k])
           xh+=value+lf
           k=k+1
        endwhile
        xh+='</history>'+lf
;
; FITS Comments
;
        xh+='<comment>'+lf
        j=jcomm
        k=0
        while (hd.(j))[k] ne '' do begin
           value = HV_XML_COMPLIANCE((hd.(j))[k])
           xh+=value+lf
           k=k+1
        endwhile
        xh+='</comment>'+lf
;
; Close the FITS information
;
        xh+='</fits>'+lf
;
; Explicitly encode the allowed Helioviewer JP2 tags
;
        xh+='<helioviewer>'+lf
;
; Original rotation state
;
        xh+='<HV_ROTATION>'+HV_XML_COMPLIANCE(strtrim(string(hd.hv_rotation),2))+'</HV_ROTATION>'+lf
;
; JP2GEN version
;
        xh+='<HV_JP2GEN_VERSION>'+HV_XML_COMPLIANCE(trim(g.source.jp2gen_version))+'</HV_JP2GEN_VERSION>'+lf
;
; JP2GEN branch revision
;
        xh+='<HV_JP2GEN_BRANCH_REVISION>'+HV_XML_COMPLIANCE(trim(g.source.jp2gen_branch_revision))+'</HV_JP2GEN_BRANCH_REVISION>'+lf
;
; HVS setup file
;
        xh+='<HV_HVS_DETAILS_FILENAME>'+HV_XML_COMPLIANCE(trim(info.hvs_details_filename))+'</HV_HVS_DETAILS_FILENAME>'+lf
;
; HVS setup file version
;
        xh+='<HV_HVS_DETAILS_FILENAME_VERSION>'+HV_XML_COMPLIANCE(trim(info.hvs_details_filename_version))+'</HV_HVS_DETAILS_FILENAME_VERSION>'+lf
;
; JP2 comments
;
        xh+='<HV_COMMENT>'+hv_comment+'</HV_COMMENT>'+lf
;
; Explicit support from the Helioviewer Project
;
        xh+='<HV_SUPPORTED>TRUE</HV_SUPPORTED>'+lf
;
; Clipping values and scaling function
;
        xh+='<HV_IMG_DMIN>'+dminString+'</HV_IMG_DMIN>'+lf
        xh+='<HV_IMG_DMAX>'+dmaxString+'</HV_IMG_DMAX>'+lf
        xh+='<HV_IMG_FUNCTION>'+hv_img_function+'</HV_IMG_FUNCTION>'+lf
;
; Close the Helioviewer information
;
        xh+='</helioviewer>'+lf
;
; Enclose all the XML elements in their own container
;
        xh+='</meta>'+lf
;
; Write the JP2 file
;
        if hd.naxis1 eq 4096 then begin
           oJP2 = OBJ_NEW('IDLffJPEG2000',loc + jp2_filename,/WRITE,$
                          bit_rate=info.details[this_wave].bit_rate,$
                          n_layers=info.details[this_wave].n_layers,$
                          n_levels=info.details[this_wave].n_levels,$
                          PROGRESSION = 'RPCL',$
                          xml=xh)
           oJP2->SetData,img
           OBJ_DESTROY, oJP2
           print,' '
           print,progname + ' created ' + loc + jp2_filename
        endif
        prepped[ii] = loc + jp2_filename
     endif else begin
        print,progname + ': data not supported'
     endelse
  endfor
  
  RETURN
END
