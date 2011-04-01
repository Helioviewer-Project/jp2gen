;
; Details on how to transfer data from the production machine to the
; server
;
; Program to create a monitoring webpage for JP2Gen
;
;
PRO HV_WEBPAGE,search = search,filename = filename,link = link,title = title
  progname = 'hv_webpage'
;
  g = HVS_GEN()
  storage = HV_STORAGE()
  wrt = HV_WRITTENBY()

  webpage = wrt.webpage
;
  br = '<BR>'
  ii = '<i>'
  iii = '</i>'
;
  if not(keyword_set(filename)) then begin
     filename = 'jp2gen_monitor.html'
  endif
;
  if not(keyword_set(title)) then begin
     title = filename
  endif
;
; Move the existing file if it already exists
;
  IF file_exist(webpage + filename) then begin
     spawn,'mv ' + webpage + filename + ' ' + webpage + filename + '.previous'
  ENDIF
;
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
  footer = ['<P>']
  if keyword_set(link) then begin
     for i = 0,n_elements(link)-1 do begin
        footer = [footer,'More: <A href='+link[i]+'>'+link[i]+'</A>']
     endfor
  endif
  footer = [footer,'<HR>']
  footer = [footer,ii+'This file written at ' + wrt.local.institute + '. Contact ' + wrt.local.contact + '.' + iii + br]
  footer = [footer,ii+g.source.contact+iii+br]
  footer = [footer,ii+'All available source code for the Helioviewer Project hosted at ' + g.source.all_code+iii+br]
  footer = [footer,ii+'JP2Gen source code hosted at ' + g.source.jp2gen_code+iii+br]
  footer = [footer,ii+'Written by JP2Gen version ' + trim(g.source.jp2gen_version) + iii+br]
  footer = [footer,ii+'Branch revision '+ trim(g.source.jp2gen_branch_revision)+iii+br] 
  footer = [footer,'</body>']
  footer = [footer,'</html>']
;
; Start the file
;
;  footer = [footer,ii+'File created by '+progname +' at ' + systime(0) +iii+br]
  text = strarr(1)
  HV_WRT_ASCII,header,webpage + filename
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
        final = strsplit(a[i],path_sep(),/extract)
        text = [text,'<B>Notification # ' + trim(i+1)+' ' +final[n_elements(final)-1] + '</B>']
        text = [text,readlist(a[i])]
        text = [text,br+br]
     endfor
  endelse
  print,progname + ':' + text[0]
  HV_WRT_ASCII,text,webpage + filename,/append
;
; End the file
;
  HV_WRT_ASCII,footer,webpage + filename,/append

  return
end
