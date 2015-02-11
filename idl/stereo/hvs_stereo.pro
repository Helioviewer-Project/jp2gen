;
; Various details about the STEREO mission.
;
FUNCTION HVS_STEREO
;
; Side lobe operation information. Taken from the operation pages
; http://stereo-ssc.nascom.nasa.gov/plans/plans2014.shtml and
; http://stereo-ssc.nascom.nasa.gov/plans/plans2015.shtml and
; http://stereo-ssc.nascom.nasa.gov/plans.shtml
;
  stereo_a_sidelobe1_dates = {start_date:['2014-08-14'], end_date:['2015-01-03']}
  stereo_a_sidelobe2_dates = {start_date:['2015-01-04'], end_date:['2015-03-23']}
  stereo_a_behind_sun_dates = {start_date:['2015-03-24'], end_date:['2015-07-07']}

  stereo_b_sidelobe1_dates = {start_date:['2014-09-28'], end_date:['2015-01-03']}
  stereo_b_sidelobe2_dates = {start_date:['no information'], end_date:['no information']}
  stereo_b_behind_sun_dates = {start_date:['2015-01-22'], end_date:['2015-03-23']}

;
; When communication was lost with STEREO B
;
  stereob_unresponsive_date = '2014-10-01'
;
; Full information
;
  answer = {stereob_unresponsive_date: stereob_unresponsive_date, $
            stereo_a_sidelobe1_dates: stereo_a_sidelobe1_dates, $
            stereo_a_sidelobe2_dates: stereo_a_sidelobe2_dates, $
            stereo_b_sidelobe1_dates: stereo_b_sidelobe1_dates, $
            stereo_b_sidelobe2_dates: stereo_b_sidelobe2_dates}

  return, answer
END
