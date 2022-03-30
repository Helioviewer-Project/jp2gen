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
;          This webpage will allow you to monitor file creation and transfer services of your JP2 installtion
;
FUNCTION HV_WRITTENBY,write_this

  ;
  supported = LIST('soho', 'stereo','trace')
  if supported.Where(write_this) eq !NULL then begin
    print,'Instrument ' + write_this + ' is not supported.'
    answer = 0
    stop
  endif else begin

    ;remote elements are now in arrays

    ;Remote users
    remote_users=['jireland1','jireland2']

    ; Remote machine
    remote_machines = ['mac1','mac2']
    nrm=n_elements(remote_machines)

    ; Local root
    local_root = 'C:\Users\jltsang\storage\trace\'

    ; Remote root where all the
    remote_root = ['rm1/user1','rm2/user2']
    inc_combined=strarr(nrm)
    inc_combined=remote_root + path_sep() + write_this + '_incoming/'

    ;Remote Groups
    remote_groups=['HV_group1','HV_group2']

    ; Locations required
    answer = {local:{institute:'NASA-GSFC',$
      contact:'Helioviewer Project (webmaster@helioviewer.org)',$
      kdu_lib_location:'~/KDU/Kakadu/v6_1_1-00781N/bin/Mac-x86-64-gcc/',$
      jp2gen_write: local_root + write_this + path_sep(), $
      jp2gen:'/home/ireland/hvp/jp2gen/jp2gen/'},$
      transfer:{local:{group:'ireland',$
      tcmd_linux:'rsync',$
      tcmd_osx:'/usr/local/bin/rsync'},$
      ;                        remote:{user:'jireland',$
      ;                                machine: remote_machine,$
      ;                                incoming: remote_root + write_this + '_incoming/',$
      ;                                group:'helioviewer'}},$
      remote:{user:remote_users,$
      machine: remote_machines,$
      incoming:inc_combined ,$
      group:remote_groups}},$
      webpage:'/service/www/',$
      manual_revision_number:'see github.com/Helioviewer-Project/jp2gen'}
  endelse
  return,answer
END

