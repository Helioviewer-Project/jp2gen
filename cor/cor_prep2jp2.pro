;
; 24 August 2009
;
; COR prep 2 JP2
;
list = scclister()

if tag_exist(list,'sc_a') then begin
   outfile = JI_HV_COR_PREP(list,'COR-A')
endif

if tag_exist(list,'sc_b') then begin
   outfile = JI_HV_COR_PREP(list,'COR-B')
endif

;
; Call details of storage locations
;
storage = JI_HV_STORAGE()

;
; The filename for a file which will contain the locations of the
; hvs EIT files.
;
;filename = ji_txtrep(date_start,'/','_') + '-' + ji_txtrep(date_end,'/','_') + '.txt'

;
; Create the location of the listname
;
;listname = storage.hvs_location + filename + '.prepped.txt'

;
; Save the prepped data list
;
;save,filename = listname,prepped

;
;
;
end
