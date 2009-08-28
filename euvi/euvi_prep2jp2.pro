;
; 24 August 2009
;
; EUVI prep 2 JP2
;
list = scclister()
n1 = n_elements(list)
t0 = systime(1)

if tag_exist(list,'sc_a') then begin
   outfile_a = JI_HV_EUVI_PREP(list,'EUVI-A')
endif else begin
   outfile_a = '-1'
endelse

if tag_exist(list,'sc_b') then begin
   outfile_b = JI_HV_EUVI_PREP(list,'EUVI-B')
endif else begin
   outfile_b = '-1'
endelse
t1 = systime(1)
;
;
;
print,'Total number of files ',n1
print,'Total time taken ',t1-t0
print,'Average time taken ',(t1-t0)/float(n1)



;
; Call details of storage locations
;
storage = JI_HV_STORAGE()

;
; The filename for a file which will contain the locations of the
; hvs EIT files.
;
filename = ji_txtrep(date_start,'/','_') + '-' + ji_txtrep(date_end,'/','_') + '.txt'

;
; Create the location of the listname
;
listname = storage.hvs_location + filename + '.prepped.txt'

;
; Save the prepped data list
;
save,filename = listname,outfile_a,outfile_b

;
;
;
end
