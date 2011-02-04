jp2gen/sdo
==========

Code to convert SDO FITS data to JPEG2000 for use with the Helioviewer Project.

Note: the code to support AIA and HMI uses less of the functionality of jp2gen/gen compared to other observatory branches of jp2gen.  This is because using jp2gen in its current form is not fast enough to keep up with the (approximate) data rate of SDO of around one image every second.

A solution to this issue is to put all the separate functions of jp2gen into one file.  This cuts down on function calls and so speeds up processing to a level where we can keep up with the SDO data rate.  Therefore when there are major changes to jp2gen/gen care must be taken to ensure that the new improved functionality is carried over to jp2gen/sdo .

For questions/comments, please contact Jack.Ireland@nasa.gov .


AIA
---

- hv_aia_list2jp2_gs2

-- converts AIA FITS files to JPEG2000 format when passed a list of AIA path + file names (corresponding to AIA FITS files that are available to you).



HMI
---

- hv_hmi_list2jp2_gs

-- converts HMI FITS files to JPEG2000 format when passed a list of HMI path + file names (corresponding to HMI FITS files that are available to you).
