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
;  default = '~hv/'.  Change as appropriate.
;
  hv_root = '~/hv/sandbox/'
;
; The subdirectory of <hv_root> where the JP2 are stored
;  default = 'jp2/'.  Change as appropriate.
;
  jp2_root = 'jp2/'
;
; ----------- No user changes required below here ----------------
;

;
; Create the necessary subdirectory locations
;
  jp2_location = hv_root + jp2_root
  if not(is_dir(jp2_location)) then spawn,'mkdir '+ jp2_location

  err_location = hv_root + 'err/'
  if not(is_dir(err_location)) then begin
     spawn,'mkdir '+ err_location
  endif

  log_location = hv_root + 'log/'
  if not(is_dir(log_location)) then begin
     spawn,'mkdir '+ log_location
  endif

;;   incoming_location = hv_root + 'incoming/'
;;   if not(is_dir(incoming_location)) then begin
;;      spawn,'mkdir '+ incoming_location
;;   endif

;;   outgoing_location = hv_root + 'outgoing/'
;;   if not(is_dir(outgoing_location)) then begin
;;      spawn,'mkdir '+ outgoing_location
;;   endif

;
; Return the structure
;
  return,{hv_root:hv_root,$
          jp2_root:jp2_root,$
          jp2_location:jp2_location,$
          err_location:err_location,$
          log_location:log_location,$
;          incoming_location:incoming_location,$
;          outgoing_location:outgoing_location,$
          NotGiven:'NotGiven'}
END
