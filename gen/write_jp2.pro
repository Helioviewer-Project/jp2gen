;+
; write_jp2.pro
; write images in JPEG 2000 format, optionally include FITS header in
; XML format
; wrapper for IDLffJPEG2000 
;
; D.M. 2008-11-13
;-

PRO write_jp2,file,image,bit_rate=bit_rate,n_layers=n_layers_jp2,n_levels=n_levels_jp2,fitsheader=fitsheader,_extra=_extra,head2struct=head2struct

; set dafaults for JPEG2000 options
IF KEYWORD_SET(bitrate_jp2) eq 0 THEN bitrate_jp2=[0.5,0.01]
IF KEYWORD_SET(n_layers_jp2) eq 0 THEN n_layers_jp2=8
IF KEYWORD_SET(n_levels_jp2) eq 0 THEN n_levels_jp2=8

IF keyword_set(head2struct) THEN header = fitshead2struct(fitsheader) ELSE $
header = fitsheader

; write FITS header into string in XML format:  
   xh = ''
   ; line feed character:
   lf=string(10b)
   ;
   ntags=n_tags(header)
   tagnames=tag_names(header) 
   jcomm=where(tagnames eq 'COMMENT')
   jhist=where(tagnames eq 'HISTORY')
   ; fix character conversion of fitshead2struct:
   indf1=where(tagnames eq 'TIME_D$OBS',ni1)
   if ni1 eq 1 then tagnames[indf1]='TIME-OBS'
   indf2=where(tagnames eq 'DATE_D$OBS',ni2)
   if ni2 eq 1 then tagnames[indf2]='DATE-OBS'

   xh='<?xml version="1.0" encoding="UTF-8"?>'+lf
   xh+='<fits>'+lf
   for j=0,ntags-1 do begin
      if j ne jcomm and j ne jhist  then begin      
         xh+='<'+tagnames[j]+' descr="">'+strtrim(string(header.(j)),2)+'</'+tagnames[j]+'>'+lf
      endif
   endfor

   xh+='</fits>'+lf
   xh+='<history>'+lf
   j=jhist
   k=0
   while (header.(j))[k] ne '' do begin
      xh+=(header.(j))[k]+lf
      k=k+1
   endwhile
   xh+='</history>'+lf
   xh+='<comment>'+lf
   j=jcomm
   k=0
   while (header.(j))[k] ne '' do begin
      xh+=(header.(j))[k]+lf
      k=k+1
   endwhile
   xh+='</comment>'

oJP2 = OBJ_NEW('IDLffJPEG2000',file,/WRITE,bit_rate=bit_rate,n_layers=n_layers_jp2,n_levels=n_levels_jp2,xml=xh)
oJP2->SetData,image
OBJ_DESTROY, oJP2

END
