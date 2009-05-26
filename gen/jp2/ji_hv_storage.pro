;
; 7 April 09
;
; Edit this file to point the code to where the output files should be
; written
; 
;
FUNCTION JI_HV_STORAGE 
;
; The root location where the programs and the jp2 files are stored
;  default = 'hv/'
;
  hv_root = '~/hv/'
;
; The subdirectory of <hv_root> where the JP2 are stored
;  default = 'jp2/'
;
  jp2_root = 'jp2/'
;
; The subdirectory of <hv_root> where the JP2 are stored
;  default = 'hvs/'
;
  hvs_root = 'hvs/'


;
; ----------- No user changes required below here ----------------
;

;
; Create the necessary subdirectory locations
;
  jp2_location = hv_root + jp2_root
  if not(is_dir(jp2_location)) then spawn,'mkdir '+ jp2_location

  hvs_location = hv_root + hvs_root
  if not(is_dir(hvs_location)) then begin
     spawn,'mkdir '+ hvs_location
  endif

  err_location = hvs_location + 'err/'
  if not(is_dir(err_location)) then begin
     spawn,'mkdir '+ err_location
  endif

;
; Return the structure
;
  return,{hv_root:hv_root,$
          jp2_root:jp2_root,$
          hvs_root:hvs_root,$
          jp2_location:jp2_location,$
          hvs_location:hvs_location,$
          err_location:err_location}
END
