JP2Gen
======

Code to convert solar FITS data to JPEG2000 format for use with the
Helioviewer Project.

For questions/comments, please contact Jack.Ireland@nasa.gov .

Many more details on using the code will be forthcoming in an updated
guide. In the meantime please use the Wayback Machine to search for
wiki.helioviewer.org. 


General purpose
---------------

/gen

- IDL-based code that is independent of any particular instrument for use with the conversion of solar FITS data to JPEG2000.

/local

- files that customize a local installation of JP2Gen.

/scripts

- various helper scripts that transfer JPEG2000 files from one location to another and monitor the performance of JP2Gen.


Observatory specific subdirectories
-----------------------------------

/hinode

- Hinode dataset specific code.

/sdo

- Solar Dynamics Observatory (SDO) dataset specific code.

/soho

- SOlar and Heliospheric Observatory (SOHO) dataset specific code.

/stereo

- Solar TErrestrial RElations Observatory (STEREO) dataset specific code.

/trace

- TRansition Region and Coronal Explorer dataset specific code.


Notes
-----

When adding PNG color tables from IDL, make sure that element (0,0) has the
"brightest color" (corresponding to color table index 255) and element (0,255)
has the "darkest color" (corresponding to color table index 0).

