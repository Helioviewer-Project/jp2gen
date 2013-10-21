;
; 8 October 2013
; Create a image/file identifier name for each TRACE image
;
FUNCTION HV_TRACE_CREATE_FILE_IDENTIFIER, fitsroot, measurement, ext
  return, fitsroot + $
          '__' + $
          string(ext.year, format='(I4.4)') + string(ext.month, format='(I2.2)') + string(ext.day, format='(I2.2)') + '_' + $
          string(ext.hour, format='(I2.2)') + string(ext.minute, format='(I2.2)') + string(ext.second, format='(I2.2)') + $
          '__' + $
          measurement
END
