;
; read, compress and write JP2 files o test how fast it can go
;
file = 'test'
t1 = systime(1)
n = 1000
for i = 0,n-1 do begin
   print,i,n
;   a = readfits('/Users/ireland/hv/dat/trace-fdm/tma_20030626_073211___WL_5120.fts',fitsheader)
;   a = readfits('/Users/ireland/hv/dat/trace-fdm/tma_20030928_000225__171_5120.fts',fitsheader)
;   a = readfits('/Users/ireland/hv/dat/trace-fdm/tma_19990822_041608_1700_5120.fts',fitsheader)
   a = readfits('/Users/ireland/hv/dat/trace-fdm/tma_20041215_040900__195_5120.fts',fitsheader)
   a = bytscl(a)
   header = fitshead2struct(fitsheader)
        xh = ''
; Line feed character:
        lf=string(10b)
;
        ntags = n_tags(header)
        tagnames = tag_names(header) 
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
              xh+='<'+tagnames[j]+'>'+strtrim(string(header.(j)),2)+'</'+tagnames[j]+'>'+lf
           endif
        endfor
;
; FITS history
;
        xh+='<history>'+lf
        j=jhist
        k=0
        while (header.(j))[k] ne '' do begin
           xh+=(header.(j))[k]+lf
           k=k+1
        endwhile
        xh+='</history>'+lf
;
; FITS Comments
;
        xh+='<comment>'+lf
        j=jcomm
        k=0
        while (header.(j))[k] ne '' do begin
           xh+=(header.(j))[k]+lf
           k=k+1
        endwhile
        xh+='</comment>'+lf
;
; Close the FITS information
;
        xh+='</fits>'+lf
;
; Helioviewer XML tags
;
        xh+='<Helioviewer>'+lf
        for j=0,ntags-1 do begin
           if (where(j eq jhv) ne -1) then begin      
              if (strmid(tagnames[j],0,3) eq 'HV_') THEN BEGIN
                 reduced = strmid(tagnames[j],3,strlen(tagnames[j])-3)
                 xh+='<'+reduced+'>'+strtrim(string(header.(j)),2)+'</'+reduced+'>'+lf
              endif
           endif
        endfor
        xh+='</Helioviewer>'+lf
;
; Enclose all the XML elements in their own container
;
        xh+='</meta>'+lf
   oJP2 = OBJ_NEW('IDLffJPEG2000',file + '.jp2',/WRITE,$
                  bit_rate=[0.5,0.01],$
                  n_layers=8,$
                  n_levels=8,$
                  xml=xh)
   oJP2->SetData,a
   OBJ_DESTROY, oJP2
endfor
t2 = systime(1)
print,'time taken for ' + trim(n) + ' runs = ',t2-t1
end
