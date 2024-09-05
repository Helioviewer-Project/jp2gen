;+
; NAME: hv_rhessi_make_list
; 
; Purpose: Make flare list of concatenated flares that have images in the RHESSI image archive.  This list will be used
;   by helioviewer to know what times/energies are available.  Produces a CSV file whose fields are listed in the lines
;   starting with ';' which are the header of the file.
;  
; Written: Kim Tolbert, April 2024
; Modifications: 
;   18-Apr-2024. Include full date and time for each time field
;   15-May-2024, Add Dsun field, distance to Sun at peak time in m   
;   
; ;-

pro hv_rhessi_make_list

out = [';id,stime,ptime,etime,prate,tcounts,xloc,yloc,en_hi,dsun,ntime,nen,link', $
       ';id - RHESSI flare ID number', $
       ';stime - start time of flare  yyyy-mm-dd hh:mm:ss', $
       ';ptime - peak time of flare  yyyy-mm-dd hh:mm:ss', $
       ';etime - end time of flare  yyyy-mm-dd hh:mm:ss', $
       ';prate - peak rate in c/s', $
       ';tcounts - total counts', $
       ';xloc - x location of flare in asec', $
       ';yloc - y location of flare in asec', $
       ';en_hi - highest energy band flare was seen in, in keV', $
       ';dsun - distance to Sun in meters at peak time', $
       ';ntime - number of image time bins', $
       ';nen - number of image energy bins', $
       ";link - prepend https://umbra.nascom.nasa.gov/rhessi/rhessi_extras/flare_images_v2/ to this dir for this flare's image archive archive location", $
       '']
       

for iyear=2002,2018 do begin
  for imonth = 1,12 do begin
;for iyear=2002,2002 do begin
;  for imonth = 1,2 do begin  
    if iyear eq 2002 and imonth eq 1 then continue ; skip Jan 2002
    if iyear eq 2018 and imonth gt 3 then continue ; skip after Mar 2018
    hfile = '/data/rhessi_extras/flare_images_v2/hsi_flare_image_archive_'+ trim(iyear) + trim(imonth, '(i2.2)') + '.html'
    a = rd_ascii(hfile)
    flines = where(strpos(a,'Flare Details') ne -1, nf)
    for jf = 0,nf-1 do begin
            
      fstart = flines[jf]
      if strpos(a[fstart+1], ' - ') ne -1 then goto, nextflare
      href = strextract(a[fstart],'href="','">')
      ftimes = hsi_ar_im_dir2time(href)
      flare = hsi_ar_which_flares(tr=ftimes, count=nflare)
      if nflare eq 0 then stop,'No flares found for  ' + ftimes[0] + ' to ' + ftimes[1] 
      if nflare gt 1 then begin
        print, trim(nflare) + ' flares found for ' + ftimes[0] + ' to ' + ftimes[1] + ', ' + arr2str(flare.id_number)
        q = where(abs(flare.start_time - anytim(ftimes[0])) lt 60 and $
                  abs(flare.end_time - anytim(ftimes[1])) lt 60, nq)
        if nq ne 1 then stop, 'Not sure which flare to choose'
        flare = flare[q[0]]
        print,'Chose ' + trim(flare.id_number) + ' ' + anytim(flare.start_time,/vms) + ' ' + anytim(flare.end_time,/vms)        
      endif
                   
      flare_id = trim(flare.id_number)
      st_time = str_replace(anytim(flare.start_time, /ccsds, /truncate), 'T', ' ')
      pk_time = str_replace(anytim(flare.peak_time, /ccsds, /truncate), 'T', ' ')
      en_time = str_replace(anytim(flare.end_time, /ccsds, /truncate), 'T', ' ')
      prate = trim(flare.peak_countrate)
      totcnts = trim(flare.total_counts)
      xloc = trim(flare.position[0],'(i5)')
      yloc = trim(flare.position[1],'(i5)')
      en_hi = arr2str(trim(flare[0].energy_hi,'(i3)'),'-')
      dummy = get_sun(anytim(flare.peak_time, /ccsds), dist=sun_earth_distance_in_au)
      dsun = trim(sun_earth_distance_in_au * !CONST.AU)
      nte = stregex(a[fstart+1], '[0-9]*tx[0-9]*e', /extract)
      ntime=ssw_strsplit(nte,'tx')
      nen=str_replace(ssw_strsplit(nte,'tx', /tail), 'e', '')
      link = href
      new = arr2str([flare_id,st_time,pk_time,en_time,prate,totcnts,xloc,yloc,en_hi,dsun,ntime, nen,link], ',')
      out = [out,new]
      nextflare:
    endfor
    
  endfor
  
endfor

prstr,file='hv_list.txt',out
end

