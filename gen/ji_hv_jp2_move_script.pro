;
; 17 september
;
; Script to move JP2 files from one place to another.
;
; Input
;
PRO JI_HV_JP2_MOVE_SCRIPT,nickname, source, destination, hvs
;
; make the name of the tarball based on the hvs header
;
  tarball = (ji_hv_storage()).outgoing_location + '/' + JI_HV_FILENAME_CONVENTION(hvs,/create) + '.tar'
;
; Begin the move script
;
  cd,source,current = old_dir
  spawn,'tar cvf ' + tarball + ' .'
  spawn,'mv ' + tarball + ' ' + destination + '/.'
  cd,old_dir
;
;
;
;  spawn,'rsync -ravz ~/hv/jp2_test/2009/09/17/SOHO/EIT/EIT/  ~/hv/fake_remote_storage/2009/09/17/SOHO/EIT/EIT/

  return
end
