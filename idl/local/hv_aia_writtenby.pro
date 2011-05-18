;
; 7 April 09
;
; Edit this file to reflect your local conditions.
;
; local: local contact details
;      institute: your institute, e.g., NASA-GSFC, LMSAL, SAO, Royal Observatory of Belgium
;      contact: the person responsible for the creation of the JP2 files at your institute
;      kdu_lib_location: where your installation of the Kakadu library is, if you choose to use Kakadu instead of IDL to create JP2 files
;
; transfer: details on the transfer of JP2 files from their creation location to their storage location
;         local: details required by JP2Gen about the local/creation computer and user
;              group: the *nix group the jp2 files originally belong to
;              tcmd_linux:  the transfer command used by linux installations (should not need to change this)
;              tcmd_osx: the transfer command used by Mac OS X installations (should not need to change this)
;         remote: details required by JP2Gen about the remote/storage computer and user
;               user: the remote user account
;               machine: the name of the machine
;               incoming: the incoming directory where the files will be stored
;               group: the remote group name required by the rest of the Helioviewer Project
;
; webpage: the location of the JP2Gen monitoring webpage.  
;          This webpage will allow you to monitor file creation and transfer services of your JP2 installation
;
FUNCTION HV_AIA_WRITTENBY
  return,{local:{institute:'NASA-GSFC',$
                 contact:'Helioviewer Project (webmaster@helioviewer.org)',$
                 kdu_lib_location:'~/KDU/Kakadu/v6_1_1-00781N/bin/Mac-x86-64-gcc/',$
                 jp2gen_write:'/home/ireland/JP2Gen_test/',$
                 jp2gen:'/home/ireland/hv/jp2gen-jack/'},$
          transfer:{local:{group:'ireland',$
                           tcmd_linux:'rsync',$
                           tcmd_osx:'/usr/local/bin/rsync'},$
                    remote:{user:'ireland',$
                            machine:'delphi.nascom.nasa.gov',$
                            incoming:'/home/ireland/test/',$
                            group:'helioviewer'}},$
          webpage:'/service/www/'}
END

