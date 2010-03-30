;
; Details on how to transfer data from the production machine to the
; server
;
; Program to create a monitoring webpage for JP2Gen
;
;
PRO HV_WEBPAGE,cadence,details_file = details_file,search = search
  progname = 'hv_webpage'
;
  if NOT(KEYWORD_SET(details_file)) THEN details_file = 'hvs_gen'
; 
  info = CALL_FUNCTION(details_file)
;
  storage = HV_STORAGE()
  web = info.web
  wrt = HV_WRITTENBY()
;
  br = '<BR>'
  ii = '<i>'
  iii = '</i>'
;
  filename = 'jp2gen_monitor.html'
;
  title = 'JP2Gen: FITS to JP2 monitor'
  header = strarr(8)
  header[0] = '<html>'
  header[1] = '<head>'
  header[2] = '<meta http-equiv="Content-Language" content="en-us">'
  header[3] = '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
  header[4] = '<title>' + title + '</title>'
  header[5] = '</head>'
  header[6] = '<body>'
  header[7] = '<h1 align="center">' + title +'</h1>' + br + br
;
  footer = strarr(1)
  footer[0] = '<HR>'
  footer = [footer,ii+'This file written at ' + wrt.local.institute + '. Contact ' + wrt.local.contact + '.' + iii + br]
  footer = [footer,ii+wrt.source.contact+iii+br]
  footer = [footer,ii+'All available source code for the Helioviewer Project hosted at ' + wrt.source.all_code+iii+br]
  footer = [footer,ii+'JP2Gen source code hosted at ' + wrt.source.jp2gen_code+iii+br]
  footer = [footer,ii+'Written by JP2Gen version ' + trim(wrt.source.jp2gen_version)+iii+br]
  footer = [footer,ii+'Branch revision '+ trim(wrt.source.jp2gen_branch_revision)+iii+br] 
  footer = [footer,'</body>']
  footer = [footer,'</html>']
;
;
;
  t0 = systime(0)
  count = 0
  repeat begin
;
; Start the file
;
     footer[0] = ii+'File created by '+progname +' at ' + systime(0) +iii+br
     text = strarr(1)
     HV_WRT_ASCII,header,web + filename
;
; Get a list of the txt files and their subdirectories in the web directory
;
     if not(keyword_set(search)) then search = '*.txt'
     sdir = storage.web
     a = file_list(find_all_dir(sdir),search)

     if not(isarray(a)) then begin
        text[0]= 'No files found with search term "'+ search + '"'
     endif else begin
        n = long(n_elements(a))
        text[0] = ii+'Number of notifications found with search term "' + search + '"= ' + trim(n) + iii + br + br + br
        for i = 0, n-1 do begin
           text = [text,'<B>Notification # ' + trim(i+1)+'</B>']
           text = [text,readlist(a[i])]
           text = [text,br+br]
        endfor
     endelse
     print,progname + ':' + text[0]
     HV_WRT_ASCII,text,web + filename,/append
;
; End the file
;
     HV_WRT_ASCII,footer,web + filename,/append
;
; Wait "cadence" minutes before re-creating the web page
;
     count = count + 1
     HV_REPEAT_MESSAGE,progname,count,t0,/web
     HV_WAIT,progname,cadence,/minutes,/web

  endrep until 1 eq 0

  return
end
