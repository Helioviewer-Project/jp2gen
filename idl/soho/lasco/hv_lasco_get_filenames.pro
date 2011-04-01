;======================== header ===============================================
;+
; NAME:
;   cactus_download_lasco 
; PURPOSE:
;   gets several days of lasco images from data repository
; 
; CATEGORY:
;   cactus 
; INPUTS:
;   julday = an array containing the start- and enddate in julian calendar (is given by jul_startend)
; 
; KEYWORD PARAMETERS:
;   /no_logfile: to print diagnostics to a no_logfile (default=stdout=screen)
;   instrument  'c2' or 'c3'     
;
; OUTPUTS:
;
; COMMON BLOCKS: 
;   none
;
; CALLS:
;   cactus_loginfo 
;   cactus_preamble
;   cactus_startend   
;     
; TO DO: 
;     
;     
; MODIFICATION HISTORY:
;   2008/03/13, ER, Created (extracted from cactus_getdata.pro)
;   2008/03/17, ER, Replace 'instrument' with 'detector' this is the name of 'c2' and 'c3' and 'COR2' in the header
;   2008/04/02, ER, Do not download data, but only a list of images containing the full path
;   2008/05/16, JMK, Check if file exist before addding to goodfiles
;-  2009/11/09, ER, Fix check for prepped files: the listofimages is checked against files listed in dir.in+detector 
;========================== end header =====================================================
FUNCTION HV_LASCO_GET_FILENAMES, t1,t2, nickname,info
  progname = 'HV_LASCO_GET_FILENAMES'
;
; JP2Gen required
;
  g = HVS_GEN()
;
  ldr = getenv('LZ_IMG') + '/' + 'level_05/' ; where the LASCO data is
;
; If we are calling this program to get the quicklooks, change ldr
;
  if tag_exist(info,'called_by') then begin
     if HV_USING_QUICKLOOK_PROCESSING(info.called_by) then begin
        ldr = info.local_quicklook
     endif
  endif

  if nickname eq 'LASCO-C2' then begin
     filter = 'Orange'
     detector = 'c2'
  endif
  if nickname eq 'LASCO-C3' then begin
     filter = 'Clear'
     detector = 'c3'
  endif

  date1 = anytim2utc(t1)
  date2 = anytim2utc(t2)
  image_list = [g.MinusOneString]

  FOR mjd=date1.mjd,date2.mjd DO BEGIN
     newday = {mjd:mjd,time:0.0}
     nds = utc2str(newday,/date_only)
     day=STRMID(nds,2,2)+STRMID(nds,5,2)+STRMID(nds,8,2)
       ; get img_hdr.txt to see which images we need to download
;         sourcefile    = dir.data+day+'/'+detector+'/'+'img_hdr.txt'
     sdir = ldr + day + path_sep() + detector + path_sep()
     sourcefile    = sdir +'img_hdr.txt'

     hvs = {img:-1,header:-1,measurement: info.details[0].measurement,$
            yy:STRMID(nds,0,4),mm:STRMID(nds,5,2),dd:STRMID(nds,8,2),$
            hh:'log', mmm:'log', ss:'log', milli:'log',$
            details:info}

     IF file_test(sourcefile) THEN BEGIN
                                ; read img_hdr.txt
        openr,dlu,sourcefile,/get_lun
        listofimages=' '
        line=' '
        REPEAT BEGIN
           readf,dlu,line
           listofimages=[listofimages, line]
        ENDREP UNTIL (eof(dlu))
        close,dlu & free_lun,dlu
        listofimages=listofimages[1:*]
                                ; select images which need to be downloaded
        nimages=n_elements(listofimages)
        downloads=' '
        for i=0, nimages-1 do begin
           words=strsplit(listofimages[i],' ',/extract)
           if (n_elements(words) lt 12) then begin
              log_comment = progname + ': img_hdr.txt malformed for this file: '+sourcefile
              print, log_comment
              HV_LOG_WRITE,hvs,log_comment
           endif else begin
              file=strsplit(words[0],'.',/extract)
              newfile = sdir + words[0]
;
; On 2011/03/09 and onwards, LASCO changed one of the 'words' in their
; list which caused JP2Gen not to pick up the availability of
; files. 2011/03/09 = 55629 in Modified Julian Days
;
              if words[11] EQ 'Normal' and (mjd lt 55629) then begin
                 words11GoodBad = 1
              endif else begin
                 if words[11] EQ 'Seq' and  (mjd ge 55629) then begin
                    words11GoodBad = 1
                 endif else begin
                    words11GoodBad = 0
                 endelse
              endelse
              good = (words[9] EQ filter) and (words[10] EQ 'Clear') and ( words11Goodbad ) and (file_exist(newfile)) and (words[5] eq '1024') and (words[6] eq '1024') 
              IF  good THEN image_list=[image_list, newfile]
           endelse
        endfor
     ENDIF ELSE BEGIN 
        HV_LOG_WRITE,hvs,progname + ': Could not open '+sourcefile
     ENDELSE
  ENDFOR                        ; juldays

  if n_elements(image_list) eq  1 then  begin
     print,' NO IMAGES ARE FOUND: CHECK YOUR INPUT DATES'
  endif else begin
     image_list=image_list[1:*]
     HV_LOG_WRITE,hvs,image_list

;     printf, log, ' Number of images that will be downloaded: ',n_elements(image_list) 
;     save, filename=dir.work+detector+'_image_list.sav', image_list
;     printf, log, image_list
  endelse

; ------------------------closing remarks-------------------------------
;  cactus_loginfo, myname, log, no_logfile=no_logfile, /close

  return,image_list
END 
