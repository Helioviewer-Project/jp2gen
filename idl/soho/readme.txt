jp2gen/soho
===========

Scripts to convert SOHO data to JPEG2000 format for use with the Helioviewer Project.

For questions/comments, please contact Jack.Ireland@nasa.gov .


SOHO
----

EIT
---
Assumes that the EIT archive is mounted and available to you.  You must also have SSW with EIT.

- hv_eit_prep2jp2_auto

-- converts data in the archive to JPEG2000.  Will look for new data and convert it as it becomes available in the archive


LASCO C2 / C3
-------------
Assumes that the LASCO quicklook data archive is mounted and available to you.  You must also have SSW with LASCO.

- hv_lasco_prep2jp2_ql, /c?

-- converts LASCO C2 or C3 quicklook data in the archive to JPEG2000, depending on the switch /c? = /c2 or /c3.  Will look for new data and convert it as it becomes available in the archive.


MDI
---
Assumes that the MDI quicklook data archive is mounted and available to you.  You must also have SSW with MDI.

- hv_mdi_prep2jp2_ql

-- converts data in the archive to JPEG2000.  Will look for new data and convert it as it becomes available in the archive



Typical procedures used for converting EIT, LASCO C2/C3 and MDI to JPEG2000
---------------------------------------------------------------------------

hv_eit_prep2jp2_auto,date_start = '2010/09/23',/copy2outgoing,details_file = 'hvs_highbitrate_eit'

hv_lasco_prep2jp2_ql,/c3,/alternate_backgrounds,/copy2outgoing,details_file = 'hvs_highbitrate_lasco_c3'

hv_lasco_prep2jp2_ql,/c2,/alternate_backgrounds,/copy2outgoing,details_file = 'hvs_highbitrate_lasco_c2'

hv_mdi_prep2jp2_ql,/copy2outgoing,details_file = 'hvs_highbitrate_mdi',date_start = '2010/09/23'


Transfer and web updating
-------------------------

hv_jp2_transfer_schedule,15,/web,/delete_transferred,/force_delete

hv_jp2gen_monitor,15

