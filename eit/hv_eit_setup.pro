;+
; hv_eit_setup.pro
; batch file to define hv structure
; D.M. 2010-02-04
;-


prop_obs={obs:'SOHO',ins:'EIT',det:'EIT',mes:['171','195','284','304']}
prop_jp2={bitrate:[0.5,0.01],nlayers:8, nlevels:8,bitdepth:8}
prop_eitscaling={t_val:[1200., 1000., 120., 700.],min_val:[7., 5., 0.3, 0.5]}

; Intensity scaling:
; latest scaling (Bernhard: processed all EIT data from 1996-2007 that way):
;   t_val = [1200., 1000., 120., 700.] & min_val = [7., 5., 0.3, 0.5]
; scaling used by SOHO Team in 2009:
;	t_val = [1200., 700., 70., 500.]
; DM, 2010-01-25: Jack, can you double-check the optimal values for
; min_val? Thanks!
;        min_val = [2., 1., 0.01, 0.4]
; min_val used by Jack Ireland:
;        min_val = [5., 2., 0.10, 0.5]

base_dir='hv_eit_tmp/'

; overall structure for hv meta information
; tags:
; hv.jp2 : compression parameters
; hv.obs: observation details
; hv.dir: base directory for file output
; hv.tags: additional tags for XML box
hv={jp2:prop_jp2,obs:prop_obs,dir:base_dir,eitsca:prop_eitscaling,tags:''}
