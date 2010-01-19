;
; 17 september
;
; Script to move JP2 files from one place to another.
;
; Input
;
PRO HV_JP2_MOVE_SCRIPT,nickname, source, destination, hvs
;
; make the name of the tarball based on the hvs header
;
  storage = ji_hv_storage(nickname = nickname)
;  tarball = storage.outgoing_location + '/' + HV_FILENAME_CONVENTION(hvs,/create) + '.tar'
;
; Begin the move script
;
;  cd,source,current = old_dir
;  spawn,'tar cvf ' + tarball + ' .'
;  spawn,'mv ' + tarball + ' ' + destination + '/.'
;  cd,old_dir

;
; rsync
;
  print,'Transferring data...'
  cd,storage.jp2_location,current = old_dir
;  spawn,'rsync -avxR .  ~/hv/fake_remote_storage'
;  spawn,'rsync -avxR --exclude "*.DS_Store" .  ~/hv/fake_remote_storage'
;  spawn,'rsync -Ravxz --exclude "*.DS_Store" ./ -e ssh -l ireland@delphi.nascom.nasa.gov:/home/ireland/jp2_test/'
  spawn,'rsync -Ravxz --exclude "*.DS_Store" ./ -e ssh -l ireland@delphi.nascom.nasa.gov:/var/www/jp2/v0.6/inc/test_transfer/'
  cd,old_dir
  return
end
