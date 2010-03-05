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
     print,'*************************'
     print,'Files written by ' + progname
     print,'Total number of files ',n1
     print,'Total time taken ',tt
     print,'Average time taken ',av
     print,'*************************'
  endif else begin
     print,'*************************'
     print,'No files written'
     print,'Total time taken ',tt
     print,'*************************'
  endelse
     if keyword_set(report) then begin
        report = {progname:progname,total_time:tt,average_time:av,nfiles:n1}
     endif
  return
end
