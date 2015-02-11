;
; Program that determines the manner of the contact of each STEREO
; spacecraft.
;

FUNCTION _HV_FIND_STATUS, sd, ed, this_time, status
  i = -1
  exit_flag = -1
  return_status = 'undecided'

  check_these = [-1]
  for i = 0, n_elements(sd)-1 do begin
     if (sd[i] ne 'no information') or (ed[i] ne 'no information') then begin
        check_these = [check_these, i]
     endif
  endfor
  if n_elements(check_these) gt 1 then begin
     check_these = check_these[1: n_elements(check_these)-1]
     for i = 0, n_elements(check_these)-1 do begin
        tstart = anytim2tai(sd[check_these[i]])
        tend = anytim2tai(ed[check_these[i]])
        if (this_time ge tstart) and (this_time le tend) then begin
           return_status = status
        endif 
     endfor
  endif
  return, return_status
END


FUNCTION HV_STEREO_DETERMINE_SIDELOBE_USAGE,spacecraft, date
;
; Get the STEREO information
;
  info = HVS_STEREO()
;
; Determine which spacecraft
;
  if spacecraft eq 'ahead' then begin
     sc = info.a
  endif else begin
     sc = info.b
  endelse
;
; Date we wish to inquire about
;
  this_time = anytim2tai(date)
;
; Default status
;
  status = 'default'
;
; Check the status
;

  sd = sc.sidelobe1_dates.start_date
  ed = sc.sidelobe1_dates.end_date
  sidelobe1_status = _HV_FIND_STATUS(sd, ed, this_time, 'sidelobe1')

  sd = sc.sidelobe2_dates.start_date
  ed = sc.sidelobe2_dates.end_date
  sidelobe2_status = _HV_FIND_STATUS(sd, ed, this_time, 'sidelobe2')

  sd = sc.behind_sun_dates.start_date
  ed = sc.behind_sun_dates.end_date
  behindsun_status = _HV_FIND_STATUS(sd, ed, this_time, 'behindsun')

  sd = sc.nominal_dates.start_date
  ed = sc.nominal_dates.end_date
  nominal_status = _HV_FIND_STATUS(sd, ed, this_time, 'nominal')

  possible_states = [sidelobe1_status, sidelobe2_status, behindsun_status, nominal_status]

  i = where(possible_states ne 'undecided')

  return, possible_states[i]
END
