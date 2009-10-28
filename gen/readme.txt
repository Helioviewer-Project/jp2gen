Converting your FITS files from FITS to JP2 for use with the Helioviewer Project

1. Define the hierarchy

(a) OBSERVATORY
(b) INSTRUMENT
(c) DETECTOR
(d) MEASUREMENT

i.e., for EIT

(a) OBSERVATORY = SOHO
(b) INSTRUMENT = EIT
(c) DETECTOR = EIT
(d) MEASUREMENT = 171, 195, 284, 304

For the STEREO mission, each spacecraft is treated as a separate observatory

(a) OBSERVATORY = STEREO-A
(b) INSTRUMENT = SECCHI
(c) DETECTOR = COR1
(d) MEASUREMENT = white-light

From this we define the observer

OBSERVER = OBSERVATORY + INSTRUMENT + DETECTOR

Each OBSERVER has a NICKNAME, which is the common and distinct name
for a given OBSERVER.


(2)  Edit the file JI_HV_OIDM2.  Edit the "nicknames" array to include
the  common and distinct name for the new OBSERVER.

For example, let us assume there is a new telescope that is
commonly known as "ZAP", and that there are three spacecraft in the
mission "MAXWELL".

(a) OBSERVATORY = MAXWELL-C
(b) INSTRUMENT = CONKER
(c) DETECTOR = ZAP
(d) MEASUREMENT = magnetogram, 1600, white-light

then

	 nicknames = ['LASCO-C2','LASCO-C3','EIT','MDI',$
				'EUVI-A','COR1-A','COR2-A',$
				'EUVI-B','COR1-B','COR2-B,$
				'ZAP-C']

The spacecraft designation goes along with the common name for the
OBSERVER.

(2)  Edit the file JI_HV_OIDM2.  Include the information above as

     If name eq 'ZAP-C' then begin
        observatory = 'MAXWELL-C'
        instrument = 'CONKER'
        detector = 'ZAP'
        measurement = ['magnetogram','1600','white-light']
     endif


All the MEASUREMENT entries should be included as strings.

(2)  Edit JI_HV_STORAGE as instructed in the header.

(3)  Edit JI_HV_OBSERVER_DETAILS to tell the system how to handle each
type of measurement the OBSERVER makes.  This is indexed by the
NICKNAME:


;
; ###############################################
;
;                            MAXWELL-C
;
; ZAP
;
     case name of
        'ZAP-C':   case measurement of
           'magnetogram': jp2 = jp2_default
           '1600': jp2 = jp2_default
           'white-light': jp2 = {n_layers:8,n_levels:8,bit_rate:[4.0,0.01],idl_bitdepth: 8}
       endcase


In the case above, the 'magnetogram' and '1600' MEASUREMENTs will be
encoded using the standard JP2 encoding parameters.  The MEASUREMENT
'white-light' requires a higher bit rate and so other parameters are
set.  Use the default value if you don't know what else to use.


At this point, the software has been told all it needs about the
nature of the new OBSERVATIONS and where to store them.  The next step
is to create the program that converts the source FITS files to a JP2
file.  This is a bit more involved and requires the use of whatever
software you would use to take a FITS file from the archive and turn
it something you would use for science, or at worst, just plain
display.



