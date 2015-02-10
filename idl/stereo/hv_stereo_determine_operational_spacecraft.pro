;+
; Project     :	JP2Gen
;
; Name        :	HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT
;
; Purpose     :	Determine which spacecraft are operational at a given time
;
; Category    :	STEREO, SECCHI, Helioviewer
;
; Explanation :	Determine which spacecraft are operational at a given
;               time by comparing the input time to the date at which
;               contact was lost with STEREO-B
;
; Syntax      :	HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT, DATE
;
; Examples    :	HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT, '2010-12-01'
;
; Inputs      :	DATE = a date in any format acceptable to any2tim2tai
;
; Opt. Inputs :	None.
;
; Outputs     :	Which of the STEREO spacecraft are operational
;
; Opt. Outputs:	None.
;
; Calls       :	ANYTIM2TAI,
;
; Common      :	None
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 10-Feb-2015, Jack Ireland GSFC
;
; Contact     :	Jack Ireland
;-
FUNCTION HV_STEREO_DETERMINE_OPERATIONAL_SPACECRAFT,date
  stereo_information = HVS_STEREO()
  stereob_unresponsive_date = stereo_information.stereob_unresponsive_date
  if anytim2tai(date) le anytim2tai(stereob_unresponsive_date) then begin
     sc = ['ahead', 'behind']
  endif else begin
     sc = ['ahead']
  endelse
  return, sc
END
