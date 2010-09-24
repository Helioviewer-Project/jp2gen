function eit_file2path, files, exist, exist_count,  $
   collapse=collapse, topeit=topeit, curdirx=curdirx, lz=lz, gavroc=gavroc
;+
;   Name: eit_file2path
;
;   Purpose: translate eit file name to "standard path" on local system
;
;   Input Parameters:
;      files - one or more eit file names (with or without path)
;      
;   Output Parameters:
;      exist       -  boolean vector - <files> online?
;      exist_count -  count where(<files>) online
;
;   Keyword Parameters:
;      topeit   - top level directory (default=EIT_QUICKLOOK)
;      curdir   - if set, set topeit to current directory
;      lz       - if set, set topeit to EIT_LZ and use YYYY/MM format
;      collapse - if set, assme all files in single directory <topeit>
;		  default is GSFC standard topeit/YYYY/MM/DD/filename
;      gavroc   - set if running on gavroche, special directory structure
;                 otherwise will check
;
;   Calling Sequence:
;      eitpath=eit_file2path(eitfilenames [,/collapse, /curdir, topeit='xxx'])
;      eitpath=eit_file2path(filenames,exist,count) 	; exist = online?
;
;   Calling Examples:
;      print,eit_file2path('efr19960521.043112')         ; "GSFC-like" tree
;         ....ate/data/processed/eit/quicklook/1996/05/21/efr19960521.043112
;
;      print,eit_file2path('efr19960521.043112',/collapse)   ; collapsed tree
;         ...ate/data/processed/eit/quicklook/efr19960521

;      print,eit_file2path('efr19960521.043112',/curdir)      ; local version
;         /usr/users/freeland/dev/eitpath/efr19960521.043112
;         
;   History:
;            21-May-1996 (S.L.Freeland) 
;            22-May-1996 (S.L.Freeland) - added 2nd param (exist)
;            01-Aug-1996 (J. Newmark) - added lz keyword for level-zero data
;            16-Aug-1996 (J. Newmark) - added special paths for GAVROC
;            21-Jan-1997 (J. Newmark) - use is_gsfcvms function
;            04-Mar-1997 (J. Nemwark) - allow input of short catalog listing
;            28-Mar-1997 (S. Freeland) - check 'EIT_DATA_STYLE' to allow
;                                        site specification ('collapsed')
;            12-May-1998 (J. Newmark) - allow combination of QKL and LZ
;                                       fix archive location on IS_GSFCVMS
;            22-Jul-1998 (J. Newmark) - fix multiple yr/month in LZ data
;                                       on VMS
;            27-Jan-1998 (J. Newmark) - bug in LZ/QKL combination
;            13-Jan-2010 (Zarro, ADNET) - fix Y2010 issue with filenames
;
;   Restrictions:
;     assume filenames in given call have same length prefix
;-
if not data_chk(files,/string) then begin
   prstr,["You must supply at least one file name...",$
          "Example: IDL> localfile=eit_file2path(file [,exist, exist_count])"]
   return,''
endif

;
; allow parsing of string output from eit_catrd
zfiles = strlowcase(files)
nfiles = n_elements(zfiles)
ftc = strmid(zfiles(0),0,2)

lz = where(strpos(zfiles,'efz') ne -1,lcnt)
if lcnt eq 1 then lz = lz(0)
ql = where(strpos(zfiles,'efr') ne -1,qcnt)
if qcnt eq 1 then ql = ql(0)


if ftc eq '19' or ftc eq '20' then begin
      if lcnt gt 0 then zfiles(lz) = strmids(zfiles(lz), strpos(zfiles(lz),$ 
                                      'efz'), 18)
      if qcnt gt 0 then zfiles(ql) = strmids(zfiles(ql), strpos(zfiles(ql),$
                                      'efr'), 18)
endif

if lcnt + qcnt eq 0 then begin
         lz = 1
         odate=anytim2utc(/external,strmids(zfiles,0,20))
         for i = 0, nfiles-1 do begin
            tname = strarr(6)
            for j = 0, 5 do tname(j) = strtrim(odate(i).(j),2)
            short = where(strlen(tname) eq 1)
            if short(0) ne -1 then tname(short) = '0' + tname(short)
            zfiles(i)='efz'
            for j = 0, 2 do zfiles(i) = zfiles(i)+tname(j)
            zfiles(i)=zfiles(i)+'.'
            for j = 3, 5 do zfiles(i) = zfiles(i)+tname(j)
         endfor
endif
;

if nfiles eq 1 then retval='' else retval = strarr(nfiles)

; check if on gavroche, xanado, eitv0, magda
if keyword_set(gavroc) or is_gsfcvms() then begin
     today=anytim2utc(!stime)
     break_file,zfiles,xlog,xpath,xfiles,xext,xvers
     ll=strlen(xfiles(0))				 
     year=strmid(xfiles,ll-8,4) & month=strmid(xfiles,11-4,2) 
     day=strmid(xfiles,11-2,2)

     dum=EXECUTE("stat=trnlog('LZ_DATA',translz,/full)")
     dum=EXECUTE("stat=trnlog('QKL_DATA',transql,/full)")

     endlz='['+year+'.'+month+']' 
     endql='['+year+'.'+month+'.'+day+']'

     date=anytim2utc(year+'/'+month+'/'+day)
     date_diff=today.mjd-date.mjd
     if stat eq 1 then begin
          case 1 of
            is_gsfcvms() eq 3: begin
                   if lcnt gt 0 then retval(lz) = translz(0) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(0) + ':' + endql
                   end
            date_diff(0) le 30: begin
                   if lcnt gt 0 then retval(lz) = translz(0) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(0) + ':'
                   end
            else: begin
                   if lcnt gt 0 then retval(lz) = translz(1) + ':' + endlz
                   if qcnt gt 0 then retval(ql) = transql(1) + ':' + endql
                  end
          endcase 
     endif else retval=getenv('REF_DIR')
     retval=retval+xfiles+xext
     if n_params() gt 1 then begin		; optionally check if online
        exist=file_exist(retval)		; files exist?
        online=where(exist,exist_count)
     endif
  return, retval
endif

collapse=keyword_set(collapse) or keyword_set(curdirx) or $
         strlowcase(get_logenv('EIT_DATA_STYLE')) eq 'collapsed'

break_file,zfiles,xlog,xpath,xfiles,xext,xvers	; remove existing path, if any
ll=strlen(xfiles(0))				; 

toplz=get_logenv('EIT_LZ') 
topql=get_logenv('EIT_QUICKLOOK')	

year=strmid(xfiles,ll-8,4) & month=strmid(xfiles,11-4,2) & day=strmid(xfiles,11-2,2)

; JSN, 1999-11-22 add new code for temporary archive switch
;toplz1=get_logenv('EIT_LZ1') 
;if toplz1 ne '' then begin
;  if strpos(toplz1,'/service/soho-arch03/home') eq -1 then $
;     if year(0) eq '1996' or year(0) eq '1997' then toplz = toplz1
;endif
;

if collapse then begin
  if keyword_set(curdirx) then retval = concat_dir(curdir(),xfiles+xext) else begin	
    if lcnt gt 0 then retval(lz) = concat_dir(toplz,xfiles+xext) 
    if qcnt gt 0 then retval(ql) = concat_dir(topql,xfiles+xext) 
  endelse
endif else begin
  if lcnt gt 0 then retval(lz) = concat_dir(toplz,concat_dir(year,$
       concat_dir(month,xfiles(lz)+xext)))
  if qcnt gt 0 then retval(ql) = concat_dir(topql,concat_dir(year(ql),$
       concat_dir(month(ql), concat_dir(day(ql),xfiles(ql)+xext(ql)))))
endelse

; case convert (convert to local convention)
retval=call_function((['strlowcase','strupcase'])(!version.os eq 'vms'),retval)

if n_params() gt 1 then begin		; optionally check if online
   exist=file_exist(retval)		; files exist?
   online=where(exist,exist_count)
endif

return,retval
end
