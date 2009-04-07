;isolates the endpoints of runs within input index.
;isolated indeces are repeated
;example:
;index_ends([4,6,7,8,16]) = [4,4,6,8,16,16]
;

function index_ends,ind0,count

ind=ind0[uniq(ind0,sort(ind0))]

n=n_elements(ind)

if n eq 1 then begin
	count=2
	return,[ind,ind]
endif

d=ts_diff(ind,1)

;find single points
ind2=where(d lt -1 and shift(d,1) ne -1,cnt0)
if cnt0 gt 0 then begin
	if d[n-2] lt -1 then ind2=[ind2,n-1]
	indf0=[ind[ind2],ind[ind2]]
endif

;find end points of runs
ind2=where(d eq -1 or shift(d,1) eq -1,cnt1)
if cnt1 gt 0 then begin
	ind3=ind[ind2]
	d=ts_diff(ind3,1)
	ind4=where(d lt -1,cnt2)
	indf1=[ind3[0],ind3[cnt1-1]]
	if cnt2 ne 0 then indf1=[indf1,ind3[ind4],ind3[ind4+1]]
endif

if cnt0 gt 0 and cnt1 gt 0 then indf=[indf0,indf1] $
else begin
	if cnt0 gt 0 then indf=indf0
	if cnt1 gt 0 then indf=indf1
endelse

indf=indf[sort(indf)]
count=n_elements(indf)


return,indf
end