;
;
; Prep a set of EIT images between a given time range
;
; sudo /sbin/mount 129.165.40.191:/Volumes/eit /Users/ireland/SOHO/EIT
; from a X11 term
;
institute = 'NASA-GSFC'
contact = 'ADNET Systems/ESA Helioviewer Group (webmaster@helioviewer.org)'
;
rootdir = '/Users/ireland/hv/hvs2/2003/10/'
;
prepped = JI_EIT_WRITE_HVS('2003/10/01','2003/10/31',rootdir)

;
; Take a list of .hvs.sav files and write them out as
; JP2 images
;
JI_WRITE_LIST_JP2,prepped,'/Users/ireland/hv/jp2_lossy/',institute,contact

end
