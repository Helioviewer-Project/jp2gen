jp2gen/stereo
-----------

JP2Gen code that supports the STEREO mission.

For questions/comments, please contact Jack.Ireland@nasa.gov .

Instructions for use
----------------

Use the following command

HV_SECCHI_AUTO,ndaysBack = ndaysBack, $       ; number of days back from the current UT date to find data from
                   details_file = details_file,$                 ; call to an explicit details file
                   copy2outgoing = copy2outgoing,$    ; copy to the outgoing directory
                   once_only = once_only,$                    ;  if set, the time range is passed through once only
                   euvi = euvi,$                                      ; do EUVI processing (both spacecraft)
                   cor1 = cor1,$                                     ; do COR1 processing (both spacecraft)
                   cor2 = cor2                                        ; do COR2 processing (both spacecraft)

So, typically you'll want to run these three commands in three different IDL sessions

HV_SECCHI_AUTO,ndaysBack = 4, /copy2outgoing,/cor1
HV_SECCHI_AUTO,ndaysBack = 4, /copy2outgoing,/cor2
HV_SECCHI_AUTO,ndaysBack = 4, /copy2outgoing,/euvi

which will look for and create JPEG2000 files for COR1, COR2 and EUVI
