;
; parse the entered times in a simple way
;

FUNCTION HV_MDI_GET_LIST,mdidir,search_term,ds,de
;
  list = file_search(mdidir,search_term)
  nlist = n_elements(list)
;
  dummy = rfits(list[0],head=h1)  ; first observation time in list
  sh1 = fitshead2struct(h1)
  if tag_exist(sh1,'date_obs') then begin
     date_start = sh1.date_obs
  endif else begin
     date_start = sh1.t_obs
  endelse
  list_start = anytim2tai(date_start)

  dummy = rfits(list[nlist-1],head=h1) ; final observation time in list
  sh1 = fitshead2struct(h1)
  if tag_exist(sh1,'date_obs') then begin
     date_end = sh1.date_obs
  endif else begin
     date_end = sh1.t_obs
  endelse
  list_end = anytim2tai(date_end)

  rds = anytim2tai(ds) ; requested start time
  rde = anytim2tai(de) ; requested end time

  list0 = -1
  list1 = -1
  if (rds lt list_start) then begin
     print,'Requested start time earlier than any entry in the list.  Using earliest entry'
     list0 = 0
  endif

  if (rds gt list_end) then begin
     print,'Requested start time later than any entry in the list.  Stopping'
     stop
  endif

  if (rde gt list_end) then begin
     print,'Requested end time later than any entry in the list.  Using last entry.'
     list1 = nlist-1
  endif

  if (rde lt list_start) then begin
     print,'Requested end time earlier than any entry in the list.  Stopping'
     stop
  endif

  if (rde lt rds) then begin
     print,'End time earlier than start time.  Stopping'
     stop
  endif

  if (list0 eq -1) then begin
     list0 = HV_FIND_CLOSEST_IN_TIME(list,rds)
     dummy = rfits(list[list0],head=h)
     date_start = (fitshead2struct(h)).date_obs
  endif

  if (list1 eq -1) then begin
     list1 = HV_FIND_CLOSEST_IN_TIME(list,rde)
     dummy = rfits(list[list1],head=h)
     date_end = (fitshead2struct(h)).date_obs
  endif

  list = list[list0:list1]
  return,{list:list,date_start:date_start,date_end:date_end}
end
