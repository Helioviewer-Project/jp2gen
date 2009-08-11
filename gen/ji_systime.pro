;
; returns a nice version of the time just now, in string form
;
FUNCTION ji_systime,dummy
return,ji_txtrep(ji_txtrep(string(systime()),' ','_'),':','.')
end
