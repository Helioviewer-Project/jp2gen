openr,1,'list'
filename=''
k=0
window,0,xs=1024,ys=1024
while not eof(1) do begin
readf,1,filename

; !p.font=1
; device, set_font='Helvetica Bold',/TT_Font

x=readfits(filename,hdr)

fov  = EIT_FXPAR(hdr, 'OBJECT')
if fov eq 'full FOV' then begin

; eit_prep, filename, hdr, x, /cosmic
eit_prep, filename, hdr, x

k=k+1
print,k,'  ',filename

if k eq 1 then begin
old1=x
old2=x
old3=x
old4=x
endif

wave = eit_fxpar(hdr, 'WAVELNTH')

if wave eq 171 then old=old1
if wave eq 195 then old=old2
if wave eq 284 then old=old3
if wave eq 304 then old=old4

time = EIT_FXPAR(hdr, 'TIME-OBS')
date = EIT_FXPAR(hdr, 'DATE-OBS')
date_string = anytim2utc(strmid(date + ' ' + time, 0, 19), /ecs)
date_string = strmid(date_string, 0, 16)

ns=size(x)
;if ns(2) eq 1024 then x=x*4
;if ns(2) eq 1024 then x=resize(x,512,512)
;if ns(2) eq 1024 then miss=resize(miss,512,512)
;if ns(2) eq 512 then miss=resize(miss,1024,1024)
if ns(2) eq 512 then x=resize(x,1024,1024)
if ns(2) eq 512 then x=x/4

miss=x*0
ix = where(x lt 0)
if ix[0] ne -1 then miss[ix] = 1

ix = where(miss ne 0)
if ix[0] ne -1 then x(ix)= old(ix)

print,minmax(x)

if wave eq 171 then begin
eit_colors,wave
im=alog(x>7<1200)
bscale,im
tv,im
old1=x
endif

if wave eq 195 then begin
eit_colors,wave
;im=alog10(x(*,*,0)>1.6<3000)
;im=alog10(x(*,*,0))>1.2<4.2
im=alog10(x>5<1000)
bscale,im
old2=x
endif

if wave eq 284 then begin
eit_colors,wave
im=alog(x>0.3<120)
bscale,im
old3=x
endif

if wave eq 304 then begin
eit_colors,wave
im=alog(x>0.5<700)
bscale,im
old4=x
endif

tv,im
xyouts,0.01,0.01,date_string,/normal,chars=2,charthick=1
tvlct,r,g,b,/get

set_plot,'Z'
device,set_resolution=[1024,1024]
tv,im
;tvlct,r,g,b,/get
;xyouts,0.01,0.01,date_string,/normal,chars=2.0,charthick=1
im = tvrd()
xwin ;; Back to X windows

;write_gif, 'EIT_' + strmid(string(10000+k),3,5) + '.gif', im,r,g,b
write_gif, strmid(date,0,4) + strmid(date,5,2) + strmid(date,8,2) + '_' + strmid(date,11,2) + strmid(date,14,2) + '_eit_' + strmid(string(wave),9,3) + '.gif', im, r,g,b
endif

endwhile
close,1

end
