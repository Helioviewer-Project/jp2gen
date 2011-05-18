;
; 22 April 2010
;
; Version 1 of conversion of SDO data to JP2
; Based on the AIA data analysis guide.
;
; Initial version only - will probably need significant edits
;
PRO hv_aia_list2jp2_gs,list,$
                    details_file = details_file,$ ; AIA details file
                    copy2outgoing = copy2outgoing,$ ; Copy the files to an outgoing directory
                    called_by = called_by,$ ; calling program (if any)
                    transfer_direct = transfer_direct ; transfer JP2 files from local to remote direct from original JP2 archive.
  progname = 'hv_aia_list2jp2_gs'
;
; Line feed character:
;
  lf=string(10b)
;
; start time
;
  t0 = systime(1)
;
; use the default AIA file is no other one is specified
;
  info = CALL_FUNCTION('hvs_default_aia')
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
  wby = HV_AIA_WRITTENBY()
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
; Check that this FITS file is supported
;
     this_wave = where(wave_arr eq trim(hd.wavelnth),this_wave_count)
     measurement = trim(hd.wavelnth)
;     if this_wave_count eq 0 then begin
;        measurement = 'not_supported'
;     endif else begin
;        measurement = trim(hd.wavelnth)
;     endelse
;
; Construct an HVS
;
     tobs = HV_PARSE_CCSDS(hd.date_obs)
;     hvs = {dir:'',$
;            fitsname:fitsname,$
;            img:,$
;            header:hd,$
;            yy:tobs.yy,$
;            mm:tobs.mm,$
;            dd:tobs.dd,$
;            hh:tobs.hh,$
;            mmm:tobs.mmm,$
;            ss:tobs.ss,$
;            milli:tobs.milli,$
;            measurement:measurement,$
;            details:info}
;
; In the Data base already
;
;     HV_DB,hvs,/check_fitsname_only,already_written = already_written
;
; Write it if it is NOT in the database
;
;     if not(already_written) then begin
;        img = readfits(fullname) ; read the individual filename
;        HV_AIA_D2JP2,fitsname,img,hd,$
;                     jp2_filename = jp2_filename, $
;                     already_written = already_written

;
; Wavelength-dependent scaling of the image
;
;     lmin = where(img le info.details[this_wave].dataMin)
;     if lmin[0] ne -1 then begin
;        img[lmin] = info.details[this_wave].dataMin
;     endif
;
;     lmax = where(img ge info.details[this_wave].dataMax)
;     if lmax[0] ne -1 then begin
;        img[lmax] = info.details[this_wave].dataMax
;     endif

     img = (img > (info.details[this_wave].dataMin)) < info.details[this_wave].dataMax

     if info.details[this_wave].dataScalingType eq 0 then begin
        img = bytscl(img,/nan)
     endif
     if info.details[this_wave].dataScalingType eq 1 then begin
        img = bytscl(sqrt(img),/nan)
     endif
     if info.details[this_wave].dataScalingType eq 3 then begin
        img = bytscl(alog10(img),/nan)
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
; Make the storage directory: HV_WRITE_LIST_JP2_MKDIR
;
     loc = storage.jp2_location + $
           hvsi.measurement + path_sep() + $
           hvsi.yy + path_sep() + $
           hvsi.mm + path_sep() + $
           hvsi.dd + path_sep()
     if not(is_dir(loc)) then spawn,'mkdir -p '+ loc
;
; File name convention
;
     date =hvsi. yy + '_' +  hvsi.mm + '_' +  hvsi.dd
     time =  hvsi.hh + '_' +  hvsi.mmm + '_' +   hvsi.ss + '_' +  hvsi.milli
;     observer =  observatory + '_' +  instrument + '_' +  detector
     observation = 'SDO_AIA_AIA' + '_' +  measurement
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
; Explicitly encode the allowed Helioviewer JP2 tags
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
; Close the FITS information
;
     xh+='</fits>'+lf
;
; Enclose all the XML elements in their own container
;
     xh+='</meta>'+lf
;
; Write the JP2 file
;
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


     prepped[ii] = loc + jp2_filename
;     endif else begin
;        print,progname + ': file already written = '+ fitsname
;        prepped[i] = g.already_written
;     endelse
  endfor
;
; Get the full path
;
  sdir_full = HV_PARSE_LOCATION(prepped[0],/location)
;
; Remote transfer 
;
  transfer_details = ' -e ssh -l ' + $
                     wby.transfer.remote.user + '@' + $
                     wby.transfer.remote.machine + ':' + $
                     wby.transfer.remote.incoming + $
                     'v' + g.source.jp2gen_version + path_sep()
;
; Go through the entire list and find all the unique subdirectories
;
  n = n_elements(prepped)
  uniq = [g.MinusOneString]
  for i = long(0), n-long(1) do begin
;     b[i] = HV_PARSE_LOCATION(prepped[i],/transfer_path)
;        if (!VERSION.OS_NAME) eq 'Mac OS X' then begin
;           b[i] = strmid(b[i],1)
;        endif
     c = HV_PARSE_LOCATION(prepped[i],/transfer_path,/all_subdir)
     test = 0
     for j = 0,n_elements(c)-2 do begin
        dummy = where(c[j] eq uniq,count)
        if (count eq 0) then begin
           uniq = [uniq,c[j]]
           print,progname + ': will change permission on directory '+ c[j]
        endif
     endfor
  endfor
  uniq = uniq[1:*]
;
; Part of the command to change groups
;
  grpchng = wby.transfer.local.group + ':' + $
            wby.transfer.remote.group
;
; Change the group ownerships and accessibility for all the unique subdirectories
;
  nu = n_elements(uniq)
  for i = long(0), nu-long(1) do begin
     spawn,'chown ' + grpchng + ' ' + sdir_full + uniq[i]
     spawn,'chmod 775 ' + sdir_full + uniq[i]
  endfor
;
; Report time taken and number of files written
;
  nawind = where(prepped eq g.already_written,naw)
  if naw ne 0 then begin
     good = where(prepped eq g.already_written,naw,/complement)
     prepped = prepped(good)
  endif

  nm1ind = where(prepped eq g.MinusOneString,nm1)
  if nm1 ne 0 then begin
     good = where(prepped eq g.already_written,nm1,/complement)
     prepped = prepped(good)
  endif
;
; Change the group and accessibility for all the files
;
  np = n_elements(prepped)
  for i = 0,np-1 do begin
     spawn,'chown ' + grpchng + ' ' + prepped[i]
     spawn,'chmod 775 ' + prepped[i]
  endfor
;
; Transfer the files
;
; First, write out the file list as seen from wby.local.jp2gen_write /
; write / v0.8
;
  prepped2 = strarr(np)
  sdir_full_len = strlen(sdir_full)
  for i = 0,np-1 do begin
     prepped2[i] = trim(strmid(prepped[i],sdir_full_len,strlen(prepped[i])-sdir_full_len))
  endfor
  HV_WRT_ASCII,prepped2,storage.outgoing+'prepped.txt'
;
; Connect to the remote machine and transfer files plus their structure
; First cd in the root of the required directory
;
  cd,sdir_full,current = old_dir
;
;rsync --files-from=prepped.txt . -e ssh ireland@delphi.nascom.nasa.gov:/home/ireland/test3/
;rsync --files-from=prepped.txt . -e ssh remote_user@remote_machine : remote_directory
;
; Greg - the following three lines are commented out.  When you have
;        access to helioviewer or delphi, comment them out.  This will
;        transfer files to the remote machine everytime you run this procedure.
;
;  c1 = '--files-from='+storage.outgoing+'prepped.txt' + ' . '
;  c2 = '-e ssh ' + wby.transfer.remote.user + '@' + wby.transfer.remote.machine + ':' + wby.transfer.remote.incoming
;  spawn,'rsync ' + c1 + c2
;
; Go back to the old directory
;
  cd,old_dir
;
; Report the time taken for JP2 file creation and transfer
;
  HV_REPORT_WRITE_TIME,progname,t0,n_elements(prepped)
;
;
;
  RETURN
END
