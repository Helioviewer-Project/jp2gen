;
; 27 March 2012
;
; Occasionally the SECCHI catalog appears to be unreachable. This
; makes it tricky to reliably write all the SECCHI images into
; JPEG2000 format.  This function defines a subdirectory where we
; store those dates that get skipped when the catalog is unavailable
;
FUNCTION HV_SECCHI_CANTFINDCATALOG
;
;
;
  wby = HV_WRITTENBY()
  cantFindCatalogDir = wby.local.jp2gen_write + 'write/v0.8/log/cantfindcatalog/'
  spawn,'mkdir '+ cantFindCatalogDir
  return,cantFindCatalogDir
end
