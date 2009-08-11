FUNCTION ji_txtrep,a,b,c
d = a
REPEAT BEGIN
	here = strpos(d,b)
	IF (here ne -1) THEN BEGIN
		strput,d,c,here
	ENDIF
ENDREP UNTIL (here eq -1)
RETURN,d
END