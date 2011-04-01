
pro mk_jp2000_queue, q_days=q_days, cadence=cadence, top_dir=top_dir

if not exist(q_days) then q_days = 30d0
q_sec = q_days*86400d0
if not exist(cadence) then cadence = 1000d0

t_now = anytim(!stime, /ccsds)
t_now_sec = anytim(t_now)
if not exist(t0) then t0 = t_now_sec - q_sec
if not exist(t1) then t1 = t_now_sec

if not exist(size_chaunk) then size_chunk = 1000

if not exist(top_dir) then top_dir = '/archive/sdo/testdata_lev1_5/jpeg2000_server/AIA'
;if not exist(top_dir) then top_dir = '/net/castor/Users/slater/data/jpeg2000_server/AIA'
if not file_exist(top_dir) then spawn, 'mkdir ' + top_dir

if not exist(wave_arr) then $
   wave_arr = ['94', '131', '171', '193', '211', '304', '335', '1700']  ; , '1600', '4500']
n_wave = n_elements(wave_arr)
t_off_wave = dindgen(n_wave)*0.125

if not exist(index_ref) then begin
  if not exist(fn_ref) then $
    fn_ref = [ '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043817_0094.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043809_0131.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043805_0171.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043817_0193.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043806_0211.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043808_0304.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043819_0335.fits', $
               '/cache/sdo/AIA/lev0/2010/04/04/H0400/AIA20100404_043817_1700.fits']
  mreadfits, fn_ref, index_ref, data_ref
endif

if not exist(n_layers) then n_layers = 5
if not exist(n_levels) then n_levels = 5

; ----------------------

fn_suffix = 'SDO_AIA_AIA_' + strtrim(wave_arr,2) ; + '.jp2'

q_paths = ssw_time2paths(t0, t1, /daily, parent='/')

for i=0, n_wave-1 do $
  if i eq 0 then q_paths_full = top_dir + '/' + strtrim(wave_arr[i],2) + q_paths else $
    q_paths_full = [q_paths_full, top_dir + '/' + strtrim(wave_arr[i],2) + q_paths]

n_dirs = n_elements(q_paths_full)
mk_dir, q_paths_full

t_grid = anytim(timegrid(t0, t1, seconds=cadence), /ccsds)
n_times = n_elements(t_grid)
n_chunks = n_times / size_chunk
remainder = n_times mod size_chunk

; tim2jp200_filename:

for i=0, n_wave-1 do begin

; Example file name format:
;   2010_12_25__09_56_44_267__SDO_AIA_AIA_304.jp2

  t_grid_wave0 = anytim(anytim(t_grid) + t_off_wave[i], /ccsds)

  t_grid_fn0 = $
    strmid(t_grid_wave0, 0,4) + '_'  + $
    strmid(t_grid_wave0, 5,2) + '_'  + $
    strmid(t_grid_wave0, 8,2) + '__' + $
    strmid(t_grid_wave0,11,2) + '_'  + $
    strmid(t_grid_wave0,14,2) + '_'  + $
    strmid(t_grid_wave0,17,2) + '_' + $
    strmid(t_grid_wave0,20,3) + '__'  

  t_grid_fn0 = t_grid_fn0 + fn_suffix[i]

  s_len = strlen(t_grid_wave0[0])

  index_ref0 = index_ref[i]
  data_ref0 = data_ref[*,*,i]

  if n_chunks gt 0 then begin
    index_chunk = replicate(index_ref0, size_chunk)
    for j=0,n_chunks-1 do begin

      t_grid_wave_chunk = t_grid_wave0[(j*size_chunk):((j+1)*size_chunk - 1)]
      fn_chunk = t_grid_fn0[(j*size_chunk):((j+1)*size_chunk - 1)]

      date_obs_chunk = strmid(t_grid_wave_chunk, 0, s_len-2) + 'Z'
      date_d$obs_chunk = date_obs_chunk
      t_obs_chunk = strmid(anytim(anytim(t_grid_wave_chunk) + index_ref0.exptime, /ccsds), 0, s_len-2) + 'Z'
      date_chunk = strmid(anytim(anytim(t_grid_wave_chunk) + 3600d0, /ccsds), 0, s_len-5) + 'Z'

      index_chunk.date_obs = date_obs_chunk
      index_chunk.date_d$obs = date_d$obs_chunk
      index_chunk.t_obs = t_obs_chunk
      index_chunk.date = date_chunk
      index_chunk.wavelnth = long(wave_arr[i])

;      if j eq 0 then index_arr = index_chunk else index_arr = concat_struct(index_arr, index_chunk)

      for k=0, size_chunk-1 do begin
        fn0 = top_dir + '/' + strtrim(wave_arr[i],2) + $
          ssw_time2paths(index_chunk[k].date_obs, index_chunk[k].date_obs, /daily, parent='/') + '/' + fn_chunk[k]
;        mwritefits, fn0, index_chunk[k], data_ref0
        ji_hv_write_jp2_lwg, fn0, data_ref0, bit_rate=bit_rate, n_layers=n_layers, n_levels=n_levels, $
          fitsheader=index_chunk[k], quiet=quiet, kdu_lib_location=kdu_lib_location, _extra = _extra
      endfor

    endfor
  endif

  if remainder gt 0 then begin
    index_chunk = replicate(index_ref0, remainder)

    if n_chunks gt 0 then begin
      t_grid_wave_chunk = t_grid_wave0[(n_chunks*size_chunk):*]
      fn_chunk = t_grid_fn0[(n_chunks*size_chunk):*]
    endif else begin
      t_grid_wave_chunk = t_grid_wave0
      fn_chunk = t_grid_fn0
    endelse

    date_obs_chunk = strmid(t_grid_wave_chunk, 0, s_len-2) + 'Z'
    date_d$obs_chunk = date_obs_chunk
    t_obs_chunk = strmid(anytim(anytim(t_grid_wave_chunk) + index_ref0.exptime, /ccsds), 0, s_len-2) + 'Z'
    date_chunk = strmid(anytim(anytim(t_grid_wave_chunk) + 3600d0, /ccsds), 0, s_len-5) + 'Z'

    index_chunk.date_obs = date_obs_chunk
    index_chunk.date_d$obs = date_d$obs_chunk
    index_chunk.t_obs = t_obs_chunk
    index_chunk.date = date_chunk
    index_chunk.wavelnth = long(wave_arr[i])

;    if n_chunks eq 0 then index_arr = index_chunk else index_arr = concat_struct(index_arr, index_chunk)

    for k=0, remainder-1 do begin
      fn0 = top_dir + '/' + strtrim(wave_arr[i],2) + $
        ssw_time2paths(index_chunk[k].date_obs, index_chunk[k].date_obs, /daily, parent='/') + '/' + fn_chunk[k]
;      mwritefits, fn_chunk[k], index_chunk[k], data_ref0
      ji_hv_write_jp2_lwg, fn0, data_ref0, bit_rate=bit_rate, n_layers=n_layers, n_levels=n_levels, $
        fitsheader=index_chunk[k], quiet=quiet, kdu_lib_location=kdu_lib_location, _extra = _extra
    endfor

  endif

endfor

end
