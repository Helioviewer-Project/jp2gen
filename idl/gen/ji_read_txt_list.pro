;
;
; ji_read_txt_list
; read a list strings in a text file and return the
; list as a string array
;
;
FUNCTION ji_read_txt_list,source_list

close,/all
dummy = ''
n = 0
openr,1,source_list
WHILE NOT(EOF(1)) DO BEGIN
   readf,1,dummy
   n = n + 1
ENDWHILE
close,1

if (n ne 0) THEN BEGIN
   list = strarr(n)
   n = 0
   openr,1,source_list
   WHILE NOT(EOF(1)) DO BEGIN
      readf,1,dummy
      list(n) = dummy
      n = n + 1
   ENDWHILE
   close,1
ENDIF ELSE BEGIN
   list = ['<zerolengthlist>']
endelse

RETURN,list
END
