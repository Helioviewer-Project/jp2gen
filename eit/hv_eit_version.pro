;
; 7 April 09
; Version information for EIT
;
FUNCTION HV_EIT_VERSION
  loc = getenv("HV_JP2GEN") + path_sep() + 'eit'
  bzr_revno = HV_BZR_REVNO_HANDLER(loc)
  return,{revision:bzr_revno}
END
