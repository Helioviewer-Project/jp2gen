;
;
;
FUNCTION HV_JP2GEN_CURRENT,verbose = verbose
;
; Get the creation details
;
  g = HVS_GEN()
;
; Parsable text string
;
  if keyword_set(verbose) then begin
     answer = '__JP2GEN_version_' + trim(g.source.jp2gen_version) + $
              '__JP2GEN_revision_' + trim(g.source.jp2gen_branch_revision)
  endif

  return,answer
end
