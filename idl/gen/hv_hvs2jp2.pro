PRO hv_hvs2jp2, img, struc_header, dir, fitsname, comment, measurement, info
  
    
  tobs = HV_PARSE_CCSDS(struc_header.date_obs)
  
  hvsi = {  dir:dir, $ ; the directory where the source FITS file is stored,default is current dir
            fitsname:fitsname, $            ; the name of the FITS file
            header: struc_header, $ ; the ENTIRE FITS header as a structure - use FITSHEAD2STRUCT
            comment: comment, $ ; a string that contains any further information 
            measurement:measurement,$ ; the particular measurement of this FITS file
            yy:tobs.yy,$
            mm:tobs.mm,$
            dd:tobs.dd,$
            hh:tobs.hh,$
            mmm:tobs.mmm,$
            ss:tobs.ss,$
            milli:tobs.milli,$
            details:info }
  
  hvs = {img:img, $ ; a 2-d numerical array that is the image you want to write
         hvsi:hvsi $    ; a structure containing the relevant information about img
        }
  
  
  HV_MAKE_JP2,hvs               ; CONVERT IMAGES TO JP2000
  
END
