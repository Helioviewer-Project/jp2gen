AIA
---

SOHO
----

hv_eit_prep2jp2_auto,date_start = '2010/09/23',/copy2outgoing,details_file = 'hvs_highbitrate_eit'

hv_lasco_prep2jp2_ql,/c3,/alternate_backgrounds,/copy2outgoing,details_file = 'hvs_highbitrate_lasco_c3'

hv_lasco_prep2jp2_ql,/c2,/alternate_backgrounds,/copy2outgoing,details_file = 'hvs_highbitrate_lasco_c2'

hv_mdi_prep2jp2_ql,date_start = '2010/09/23',/copy2outgoing,details_file = 'hvs_highbitrate_mdi' 


Transfer and web updating
-------------------------

hv_jp2_transfer_schedule,15,/web,/delete_transferred,/force_delete

hv_jp2gen_monitor,15

