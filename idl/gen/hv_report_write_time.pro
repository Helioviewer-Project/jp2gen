;
; Guy Fawke's Day, 2009
;
PRO HV_REPORT_WRITE_TIME,progname,t0,prepped,report = report
  t1 = systime(1)
  if isarray(prepped) then begin
     n1 = n_elements(prepped)
  endif else begin
     n1 = prepped
  endelse
  tt = t1 - t0
  if (n1 ne 0) then begin
     av = tt/float(n1)
     report = ['*************************']
     report = [report,'Files written by ' + progname]
     report = [report,'Total number of files = '+trim(n1)]
     report = [report,'Total time taken = ' + trim(tt)]
     report = [report,'Average time taken = ' + trim(av)]
     report = [report,'*************************']
  endif else begin
     report = ['*************************']
     report = [report,'No files written']
     report = [report,'Total time taken = '+trim(tt)]
     report = [report,'*************************']
  endelse
  for i = 0,n_elements(report)-1 do begin
     print,report[i]
  endfor

  return
end
