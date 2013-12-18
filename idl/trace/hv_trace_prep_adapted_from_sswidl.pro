;-----------------------------------------------------------------------------
pro trace_prep, input1, input2, index_out, image_out,	              $

		normalize=normalize,   				      $
		darkdir=darkdir,	 user_dark=user_dark,	      $
		no_darksub=no_darksub,   			      $
		flatdir=flatdir, 	 no_flatfield=no_flatfield,   $

		unspike=unspike,				      $
		destreak=destreak,	 deripple=deripple,	      $
                wave2point_correct=wave2point_correct,		      $
		float=float,		 new_avg=new_avg,	      $  		
		subimgx=subimgx,	 subimgy=subimgy,	      $
		sllex=sllex,		 slley=slley,		      $
		nodata=nodata,		 no_calib=no_calib,	      $
		original=original,       outminsiz=outminsiz,	      $
		outdir=outdir,		 outtrfits=outtrfits,	      $
		outflatfits=outflatfits, qstop=qstop,		      $
		quiet=quiet,		 verbose=verbose,	      $
		n_pixel=n_pixel,	 run_time=run_time

;	***********************************************************
;		despike=despike    (TBD)
;               response_norm=response_norm 		    (TBD)
;+
; NAME:
;	TRACE_PREP
;
; PURPOSE:
;	Process  TRACE image(s).
;
;	A preliminary version of a processing routine for preparing the
;	TRACE image data for analysis.  The steps performed are:
;		1. Read in raw FITS image(s) from a filelist and  
;                    decompress the data and structure; 
;		     or read in a datacube and structure
;		2. Fill pixels of value = 0 with mean pixel value of entire 
;	       	     image
;		3. Replace near saturated pixels with values > 4095
;		4. Subtract the dark pedestal (ADC offset) & current from each 
; 		     image
;	        5. Perform ccd gain calibration and lumogen degradation 
;                    correction by dividing by time and wavelength dependent 
;                    flat field 
;		6. Options to remove radiation-belt/cosmic-ray spikes and 
; 		     streaks
;		7. Option to remove background diffraction pattern (ripple)
;		8. Option to normalize each image for exposure
;		9. Option to extract a subimage from each image
;	       10. Output the corrected image(s) in an updated structure
;		     and data cube, and optionally output a FITS file
;		     with 1 or more images plus a binary extension or as
;		     2D flat FITS files (1 per image)
;	In the future this routine may also:
;	       11. Instrument response normalization to physical units
;
; CATEGORY:
;	FITS processing
;
; SAMPLE CALLING SEQUENCE:
;       TRACE_PREP, input1, input2, [index_out, image_out] [,/outtrfits]
;		    [,outdir=outdir] [,/normalize] [,darkdir=darkdir] 
;		    [,/user_dark] [,user_dark=user_dark] [,/no_darksub] 
;		    [,flatdir=flatdir] [,/no_flatfield] [,unspike=unspike]
;		    [,/destreak] [,/deripple] [,/wave2point_correct] [,/float]
;		    [,/new_avg] [,/subimgx=subimgx] [,subimgy=subimgy] 
;		    [,sllex=sllex] [,slley=slley] [,/nodata] [,/no_calib] 
;		    [,/original] [,/outminsiz] [,/outflatfits] [,/qstop] 
;		    [,/quiet] [,/verbose] [,n_pixel=n_pixel] 
;		    [,run_time=run_time]
;
;       trace_prep, filename, image_no of hourly file, index_out, image_out
;       trace_prep, infile, dset_arr, index_out, image_out
;       trace_prep, index, data, index_out, image_out
;	trace_prep, file_list(indir,infile), ss(0:8), index, image  
;		    (with ss=lindgen(total))
;
;   Example for the beginner:
;	trace_prep, file_list(indir,infile), [0,2,4,6,8], index, image ,/unspike ,/outtrfits ,outdir=outdir
;
; INPUTS:
;		 ** There are 2 methods for calling TRACE_PREP **
;  Case	1. input1 - The input TRACE FITS filelist name(s)
;	   input2 - The dataset number(s) to extract and process
;
;  Case	2. input1 - The index structure for each of the input images
;		       (e.g., index from output of read_trace with
;			      option /image)
;	   input2 - The input data array (cube)
;
; 
; OUTPUTS (OPTIONAL):
;	index_out - The updated index structure of the input images
;	image_out - Processed output TRACE images (data cube).  
;			Default data type is I*2
;
; OPTIONAL INPUT KEYWORD PARAMETERS: 
;	normalize - Set to normalize output image to DN per sec	
; (TBD) response_norm - Set if want to include response normalization 
;	 		    to physical units				(TBD)
;	darkdir   - Directory for ~monthly dark current processed fits images,
;			default =  "concat_dir('$tdb','tdc_darks')",  which 
;			should work at most sites (including vestige and EOF)
;	user_dark - If set, read in a user supplied dark current fits image from
;			darkdir as the first image with filename given by 
;			'user_dark'.  This image is assumed to be sized, binned, 
;			and pixel aligned already.
;	no_darksub - Set to not perform dark subtraction; [default: perform it]
; 	no_flatfield - Set to not perform flat fielding correction (as done 
;			 prior to V3.0); [default: perform it]
;	flatdir   - Directory for ~quarterly flat field processed fits images,
;			default =  "concat_dir('$tdb','tdc_darks')",  which 
;			should work at most sites (including vestige and EOF)
;	unspike   - Set if 1 pass of unspike wanted to remove radiation-belt/
;			cosmic-ray spikes, or set to 1-3 passes of unspike. This
;			method uses convolution and thresholding to remove 
;		        spikes 
;			and may remove small real features.
;			[This calls CCK trace_unspike.pro & trace_cleanjpg.pro] 
; (TBD)	despike   - Set if 1 pass of despike, an alternate unspike, wanted to 
;  (NOT TURNED ON YET!)	remove radiation-belt/cosmic-ray spikes, or set to 1-3 
;			passes of despike.  This method uses a median filter or
;			a statistical correction to remove spikes and may remove 
;			small real features.   				(TBD)
;			[This calls CJS tracedespike.pro & CCK 
;			trace_cleanjpg.pro] 
;	destreak  - Set if 1 pass of destreak wanted to remove radiation belt/
;			cosmic-ray streaks (particle hits skimming the 
;			detector). This method uses convolution and thresholding 
;			for removal and may remove small real features.   
;			[This calls CCK trace_destreak.pro] 
;	deripple  - Set if 1 pass of readout noise (ripple) remover is wanted. 
;			This method identifies and zeroes spikes in FFT.
;			[This calls CCK trace_knoise.pro] 
;       wave2point_correct - set to change the pointing tags (xcen,ycen) ONLY,
;                       based on the wavelength dependent alignment corrections 
;                       contained in trace_wave2point.pro for subsequent use with 
;			Dominic Zarro's SSW mapping software, e.g., plot_map.
;                       ***NOTE that these shifts, which are focus dependent,  
;                       are only good at the wavelength focusing positions. In 
;                       recent years the latter have sometimes not been used to
;                       conserve the focus mechanism. Therefore the researcher  
;                       should separately check image alignments until this 
;                       procedure has been updated.  (RWN Nov. 2005)***  		
;	float     - Set if you want to return floating point.  [Default is I*2]
;	new_avg   - Set to recalculate img_avg, img_dev, img_min, img_max for 
;			image, this is also done upon a call to write_trace to 
;			save TRACE data cube
;	subimgx   - Set to x size of subimage for extraction and image_out size;
;			to extract a subimage set this and subimgy, sllex, slley
;	subimgy   - Set to y size of subimage for extraction and image_out size
;	sllex     - Set to lower left x position of subimage to be extracted
;	slley     - Set to lower left y position of subimage to be extracted
;       nodata    - Set if don't want output array (auto set if lt 3 params)
;	no_calib  - Set to skip calibration but not various output options
;	original  - Set if input files need more keywords for dark subtraction
;	outminsiz - Set if output datacube size to be minimum input image size, 
;			larger sized images are rebinned to this size after 
;			being processed;   [default is maximum input image size
;			with no rebinning] 
;       outdir    - Destination directory for prepped FITS files
;       outtrfits - Set if want to output a TRACE binary extension FITS file
;			with 1 or more images 
;       outflatfits - Set if want to output a 2D flat FITS file (1 per image)
;	qstop	  - Set to stop in this procedure for debuging purposes
;	quiet     - Set for fewer messages, default is loud
;	verbose   - Set for lots of messages and intermediate data listings;
;			suppresses quiet
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;	n_pixel   - Number of pixels repaired
;	run_time  - The run time in seconds for TRACE_PREP
;
; COMMON BLOCKS: none.
;
; RESTRICTIONS:
;       If the input consists of more than one image, there is no  
;       check to make sure that all the images are the same size. 
;       *** The user must be careful to check this. ***
;	In fact each image is processed separately with background
;	subtractions adjusted for the image size.  The output datacube
;	is by default sized for the largest image and zero-filled, with 
;	the images inserted into the cube afterword.  There is an 
;	option to size to the minimum image size.  The output datacube
;	will be resized to subimage if the subimage extraction option is used.
;
;	Note that the usage of the routines called by the keywords unspike, 
;	despike, destreak, and/or deripple may remove small real features 
;	in the image.
;
;	If the input is an index structure plus a data cube, the index
;	is assumed to contain more than the default set of the keywords 
;	(use '/image' in READ_TRACE; '/all_tags' may result in more then 
;	127 keywords, which may cause problems in IDL versions below 5.0)
;
; PROCEDURE:
;       Each raw image of the FITS filelist, or of the index and data array, 
;	are read in one at a time for processing.   Missing pixels are
;	replaced with the total image average value.  Near saturated pixels
;	are replaced with values > 4095, such that after dark subtraction they 
;	are still > 4100, even for the 4x4 summed values.  Then the appropriate 
;	dark pedestal (ADC offset) and the nominally small dark current are 
;	subtracted from each entire image.  Negative data values are left as 
;	they are. Next the images are flat field corrected. Options are provided
;	to call an unspike routine to remove particle and cosmic ray hits of the
;	ccd for EUV images only; call an alternate despike program; call a 
;	destreak procedure to clean, in EUV images only, streaks resulting from 
;	a cosmic ray traveling through several pixels as it skims through the 
;	ccd; and call a herringbone readout noise (~few dn ripple) remover for 
;	cleaning EUV only image backgrounds that have low intensities.  Another 
;	option is to normalize the image for the actual shutter exposure value. 
;	A subimage can be extracted from each image as an option also.  An 
;	option for updating some of the index parameters for each modified 
;	image, e.g., 'img_avg', can be selected.
;
;	In the future, corrections to the image may also be made for response
;	normalization to physical units.  Note that no pinhole leakage of foils
;	has been observed, so no corrections are needed at the present time. 
;	The images are returned as an index structure and a datacube, and 
;	optionally as a TRACE binary extension FITS file with an updated header,
;	1 or more images per file, and a filename of "tfiyyyymmdd_hhmmss", or as
;	a 2D flat FITS file (1 image per file) with a filename of 
;	"tsiyyyymmdd_hhmmss_a#.fits", where # = sai integer (0, 1, or 2).
;
;
; MODIFICATION HISTORY:
;V1.0	Completed on 15-Apr-98  by  R. W. Nightingale  based on
;           eit_prep.pro and sxt_prep.pro
;V1.1	16-Apr-98 (RWN) - Modified so darkdir can be input, if needed 	    
;V1.2   19-Jun-98 (RWN) - Implemented verbose and retrn for TR_DARK_SUB
;			- Modified so user_dark file can be supplied to 
;			  TR_DARK_SUB and dark_raw_image & _index get saved
;			- Updated procedure description and in-line comments
;			- Added image normalization capability
;			- Added counting of saturated pixels
;V1.3    6-Jul-98 (RWN) - Modified keyword info. for default 'darkdir'
;V1.4	22-Sep-98 (RWN) - In call to read_trace use /image keyword inplace of
;			  /all_tags for shorter index list
;V1.5   26-Sep-98 (RWN) - Added option for extraction of a subimage
;			- Made the updating of 'img_avg', etc an option
;			- Added pointer to dark images at EOF
;V1.6 	12-Oct-98 (RWN) - Modify default darkdir keyword documentation
;V1.7	14-Jan-99 (RWN) - Added keyword original to allow more keywords
;			- Modify "wave_num" to keyword "wave_len"
;V1.8    6-Mar-99 (SLF) - Add /WAVE2POINT_CORRECT keyword and logic
;V1.9   13-Sep-99 (RWN) - Added more calls to and used UPDATE_HISTORY and 
;			  GET_HISTORY instead of add_tag 
;			- Added unspike, destreak, despike, deripple, and quiet
;			- Updated header and procedure keyword calling sequence
;			- Updated /float option and saturated pixel handling
;			- Updated to utilize a file/ss map in reading images
;V2.0	11-Feb-00 (RWN) - Updated call to tr_ext_subimg for summed/binned images
;V2.1   14-Mar-00 (RWN) - Correct call to tr_ext_subimg for index2.tbin_ccd
;			- Add /quiet pass through to read_trace
;V3.0   23-Aug-02 (RWN) - Add TR_FLAT_SUB interface and UV flat field correction
;			- Update library call for mean and standard deviation
;V3.1	17-Sep-02 (RWN) - Include double as possible image type for data_chk
;V3.2	20-Feb-03 (RWN) - Add EUV flat field correction
;V3.2a   4-Nov-05 (RWN) - Header updates, including wave2point note
;-
;-----------------------------------------------------------------------------
;
progver = 'V3.2'
prognam = 'TRACE_PREP.PRO'
t0 = systime(1)
t1 = t0					; Keep track of running time
print, 'running ', prognam, ' ', progver, '  with flat field correction'
use_fits = 1
wavenum = ['171', '195', '284', '1216', '1550', '1600', '1700', 'WL']
;
loud = 1 - keyword_set(quiet)
verbose = keyword_set(verbose)
if (verbose eq 1) then loud = 1
no_darksub = keyword_set(no_darksub)
no_flatfield = keyword_set(no_flatfield)
original = keyword_set(original)
if (n_elements(outdir) le 0) then outdir = curdir()
yes_data = (not keyword_set(nodata)) and (n_params() gt 3)
;
if (datatype(input1) eq 'STC') then begin	; if a structure, need data array of at least 8x8
   if (n_elements(input2) gt 63)  then use_fits = 0  else begin
      message, /info, 'No Data supplied, reading FITS file...'	   ; or read FITS file
   endelse
 endif					
nfiles = n_elements(input1)
if (nfiles lt 1) then begin
  message, /continue, '*** No filename or structure supplied, returning...***'
  return
 endif

if (use_fits)  then begin  			; if a FITS file, need image number(s), default = 0
  nimages = n_elements(input2)
  if (nimages eq 0)  then begin
    nimages = 1
    input2 = 0
  endif
  ss = input2
  read_trace, input1, input2, indices, data, /image, /nodata   ; read only the FITS filelist structures
							       ; for sizing the output datacube
			; /image must be used to get keywords for dark subtraction
			; /all_tags provides too many tags that may run over the IDL limit of 127 for versions below 5.0
  if (input2(0) eq -1)  then begin			; if reading all images
    nimages = n_elements(indices)
    ss = indgen(nimages)
  endif 
  if (nimages eq 1) then begin				     ; if 1 image
    nx0 = gt_tagval(indices,/naxis1)
    ny0 = gt_tagval(indices,/naxis2)
  endif else begin					     ; if more than 1 image
    if (keyword_set(outminsiz))  then begin	; option for minimum input image size for datacube
      nx0 = min(gt_tagval(indices,/naxis1))
      ny0 = min(gt_tagval(indices,/naxis2))
    endif else begin				; default to maximum input image size for datacube
      nx0 = max(gt_tagval(indices,/naxis1))
      ny0 = max(gt_tagval(indices,/naxis2))
    endelse
  endelse
  print, 'Reading FITS filelist: ',input1,' with image_no(s) = ', input2
  if (input2(0) eq -1)  then print, ' The total number of images to be read = ',nimages
  nx2 = nx0
  ny2 = ny0
  if (keyword_set(subimgx)) then nx2 = subimgx
  if (keyword_set(subimgy)) then ny2 = subimgy
  print, 'Output datacube size will be = [', nx2, ',', ny2, ']'
 endif else begin				; not a FITS file
  nimages =  n_elements(input1)
  if (nimages eq 1) then begin				     ; if 1 image
    nx0 = gt_tagval(input1,/naxis1)
    ny0 = gt_tagval(input1,/naxis2)
  endif else begin					     ; if more than 1 image
    if (keyword_set(outminsiz))  then begin	; option for minimum input image size for datacube
      nx0 = min(gt_tagval(input1,/naxis1))
      ny0 = min(gt_tagval(input1,/naxis2))
    endif else begin				; default to maximum input image size for datacube
      nx0 = max(gt_tagval(input1,/naxis1))
      ny0 = max(gt_tagval(input1,/naxis2))
    endelse
  endelse
  ss = indgen(nimages)
  print, 'Read image structure and data for ',nimages,' images'
  print, 'Output datacube size will be = [', nx0, ',', ny0, ']'
 endelse
indices = 0					;erase indices as will be input again with data below
if (not yes_data) then print, '**No images output to datacube'	; due to /nodata or n_params() lt 4
if (keyword_set(no_calib)) then  print,'**No calibation done to images, i.e., no darks subtraction, etc.'

if (use_fits) then begin          ; make file/ss map to allow input from several hourly files
  mxf_read_header, input1, pheader, /primary
  dsmap=mxf_dset_map(pheader,ss)
endif

for i=0, nimages-1  do begin			; MAIN LOOP: begins 
						; process 1 image at a time
  if (use_fits) then begin
    image_no = dsmap(i).dset
    file1 = input1(dsmap(i).ifile)
    if (not loud) then  read_trace, file1, image_no, indexi, data, /image,  $
       original=original, /quiet  else  $
       read_trace, file1, image_no, indexi, data, /image, original=original  ; read FITS image and
						; at a sublevel rotates image so N is up!
    index0 = temporary(indexi)
    nx = gt_tagval(index0,/naxis1)
    ny = gt_tagval(index0,/naxis2)
    image0 = temporary(data)
    ni = n_elements(image0)
  endif else begin				; else read index structure and data array
    index0 = input1(i)
    image_no = i
    nx = gt_tagval(index0,/naxis1)
    ny = gt_tagval(index0,/naxis2)
    image0 = input2(*,*,i)
    ni = n_elements(image0)
    if (ni gt nx*ny) then begin
      image0 = input2(0:nx-1,0:ny-1,i)
      ni = n_elements(image0)
    endif
  endelse
  if not required_tags(index0,'img_time,amp,sum_ccdx,bin_ccd,tbin_ccd,t_ccd_a,sri_llex,sri_lley,sht_nom',  $
			missing=missing) then begin
    box_message,['The following missing tags are required',missing]
    box_message,'Use  /original  switch in trace_prep or  /image,/original  in read_trace'
    return
  endif

  if (ni lt 1)  then begin			; if no elements in image
    print, 'No elements in IMAGE #', i
    help, /str, index0				; list the image index
    message, /continue, 'No elements in IMAGE, skip to next one'
  endif else begin				; image has elements
    if (use_fits) then begin
      if (i eq 0) then begin
        file2 = file1
        print, 'File = ', file2
      endif else if (file1 ne file2) then begin
        file2 = file1
        print, 'File = ', file2
      endif
    endif
   nx2 = nx
   ny2 = ny
   if (keyword_set(subimgx)) then nx2 = subimgx
   if (keyword_set(subimgy)) then ny2 = subimgy
   wave_numi = gt_tagval(index0,/wave_len)
   print, 'For image/ ndex',image_no, '/', i, ':  Output image size will be = [', nx2, ',', ny2, '],  wavelength = ',wave_numi
    if (keyword_set(verbose)) then $
       help, /str, index0			; list the image index

; CALIBRATION: [default] replace missing and saturated pixels, dark subtract, 
;              [optional] unspike, destreak, deripple normalization, etc:

    if (not keyword_set(no_calib))  then begin	; calibrate

;  REPLACE MISSING PIXELS WITH IMAGE AVERAGE AND CHECK FOR SATURATED PIXELS
;    check .HISTORY (only apply the correction one time)
     previous = get_history(index0,caller='TRACE_DARK_SUB',found=found)
     if (not found) then begin 
      mmp = where(image0 eq 0, mcnt)		; find missing pixels
      if (mcnt ne 0) then begin		; replace if there are any missing
        nnp = where(image0 gt 0, ncnt)		; find pixels for average
        if (ncnt ne 0)  then begin
	  mean = total(image0(nnp))/ni	; find mean of image
	  if (mean gt 32767. or mean lt -32768.)  then begin		; check if I*2
	    message, /continue, 'Unexpected image mean value outside of I*2: mean = 0.'
	    mean = 0.0
	  endif
  	endif else begin
          message, /info, 'All pixels = 0'		; all pixels = 0
          mean = 0.0
        endelse
	image0(mmp) = fix(mean)		; replace missing pixels with I*2 mean value 
	n_pixel = mcnt
;    Update .HISTORY tag
        tagval0 = string('Replaced ', n_pixel, ' missing pixels with IMAGE_AVERAGE = ',  $
			 mean, format='(a,i5,a,i5)')
        if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval0
	update_history,index0,tagval0
      endif
      ssp = where(image0 ge 4000, scnt)		; find pixels near saturation
      if (scnt gt 0) then  begin
        image0(ssp) = 4400   ; replace saturated pixels with large value, so that
			     ; 1x1, 2x2 & 4x4 are still >4095 after dark subtraction
;    Update .HISTORY tag
        tagval1 = string('Replaced ', scnt, ' saturated pixels with value > 4100',  $
			 format='(a,i5,a)')
        if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval1
	update_history,index0,tagval1
      endif
     endif

;**** SUBTRACT DARK PEDESTAL (ADC offset) and DARK CURRENT (small)  (unless no_darksub set)
;    check .HISTORY (only apply the correction one time) 
     previous = get_history(index0,caller='TR_DARK_SUB',found=found)
     if (not found and not no_darksub) then begin 
      image1 = tr_dark_sub(index0, image0, nx=nx, ny=ny, darkdir=darkdir,  $
	    dark_raw_image=dark_raw_image, dark_raw_index=dark_raw_index,  $
	    version=version, retrn=retrn, user_dark=user_dark, loud=loud, verbose=verbose)
;   Update .HISTORY tag
      tagval2 = 'Subtracted dark pedestal and current ' 
      if (retrn eq 0) then begin
        if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval2
	update_history,index0,tagval2,caller='TR_DARK_SUB',version=version
      endif else  print, '*** NO dark pedestal subtracted'
     endif else  begin
      if (loud and  found) then  $
           box_message,'TR_DARK_SUB correction already applied, skipping...'
      image1 = image0
     endelse
      index1 = index0     

;**** Divide image by FLAT FIELD CORRECTION  (unless no_flatfield set)
;    check .HISTORY (only apply the correction one time) 
     previous = get_history(index1,caller='TR_FLAT_SUB',found=found)
     if (not found and not no_flatfield) then begin 
      image2 = tr_flat_sub(index1, image1, nx=nx, ny=ny, flatdir=flatdir,  $
	    verbose=verbose, loud=loud, version=version, retrn=retrn,      $
	    ff_1700_image=ff_1700_image, ff_1700_index=ff_1700_index,  $
	    ff_1600_image=ff_1600_image, ff_1600_index=ff_1600_index,  $
	    ff_1550_image=ff_1550_image, ff_1550_index=ff_1550_index,  $
	    ff_1216_image=ff_1216_image, ff_1216_index=ff_1216_index,  $
	    ff_euv_image=ff_euv_image,   ff_euv_index=ff_euv_index,    $
	    ff_wl_image=ff_wl_image,     ff_wl_index=ff_wl_index)
;   Update .HISTORY tag
      tagval12 = 'Image divided by corrected flat field' 
      if (retrn eq 0) then begin
        if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval12
	update_history,index1,tagval12,caller='TR_FLAT_SUB',version=version
      endif else  print, '*** NO flat field correction applied'
     endif else  begin
      if (loud and  found) then  $
           box_message,'TR_FLAT_SUB correction already applied, skipping...'
      image2 = image1
     endelse
      index2 = index1     

;  Unspike an EUV image to remove bright bad pixels due to rad-belt/cosmic-ray hits
      if (index2.wave_len eq '171' or index2.wave_len eq '195' or index2.wave_len eq '284') then begin
        if (keyword_set(unspike)) then begin
	  if (n_elements(unspike) gt 0) then begin
	    for j = 1, unspike  do begin
	      image2 = trace_unspike(temporary(image2), /cleanjpg)
	    endfor
            tagval3 = string('Unspiked EUV image ',unspike,' time(s) ', format='(a,i3,a)')  
	  endif else begin
	    image2 = trace_unspike(temporary(image2), /cleanjpg)
            tagval3 = 'Unspiked EUV image one time '
	  endelse  
;      Update .HISTORY tag
          if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval3
  	  update_history,index2,tagval3,caller='TRACE_UNSPIKE'
        endif
;  Despike Alternative to EUV unspike
        if (keyword_set(despike)) then begin		;alternate despike method
	  if (n_elements(unspike) gt 0) then begin
	    for j = 1, unspike  do begin
	      image2 = trace_cleanjpg(tracedespike(temporary(image2)))
	    endfor
            tagval4 = string('Despiked EUV image ',despike,' time(s) ', format='(a,i3,a)')  
	  endif else begin
	    image2 = trace_cleanjpg(tracedespike(temporary(image2)))
            tagval4 = 'Despiked image one time ' 
	  endelse  
;      Update .HISTORY tag
          if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval4
	  update_history,index2,tagval4,caller='TRACEDESPIKE'
        endif

;  Destreak an EUV image to remove bright bad streaks due to rad-belt/cosmic-ray hits
        if (keyword_set(destreak)) then begin
	  image2 = trace_destreak(temporary(image2))
;      Update .HISTORY tag
          tagval5 = 'Destreaked image ' 
          if (loud or i eq 0) then $
          print, 'HISTORY record updated for image',image_no,':  ',tagval5
	  update_history,index2,tagval5,caller='TRACE_DESTREAK'
        endif

;  Remove readout noise (~few dn ripple) from EUV image
        if (keyword_set(deripple)) then begin
  	  image2 = trace_knoise(temporary(image2))
;      Update .HISTORY tag
          tagval6 = 'Removed readout noise from image ' 
          if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval6
  	  update_history,index2,tagval6,caller='TRACE_KNOISE'
        endif
      endif

;  Extract a subimage if /subimgx is set to new x axis:
;     note: .HISTORY is checked and updated within fuction 
      if (keyword_set(subimgx)) then begin
	dark = 0
	image3 = tr_ext_subimg(index2, image2, index3, nx1=subimgx, dark=dark, $ 
	         ny1=subimgy, sri_llex0=sllex, sri_lley0=slley, $
                 tsum0=index2.tbin_ccd, verbose=verbose)
	nx0 = subimgx
	ny0 = subimgy
	nx  = subimgx
	ny  = subimgy
	tagval7 = string('Subimage extracted with lower left corner at ',  $
		  sllex,slley,' for size ', nx,' x ', ny, '  and tbin =',  $
		  index2.tbin_ccd, format='(a,i5,",",i5,a,i5,a,i5,a,i2)')
        if (loud or i eq 0) then $
          print, 'HISTORY record updated for image',image_no,':  ',tagval7
      endif else begin
	index3 = index2
	image3 = image2
      endelse

;  Renormalize to per sec if /normalize is set:
;    check .HISTORY (only apply the correction one time)
     previous = get_history(index3,caller='norm',found=found)
     if (not found) then begin 
      if (keyword_set(normalize)) then begin
        exptime = gt_tagval(index3,/sht_mdur)
        if (exptime gt 0.) then begin
	  image3 = image3 / exptime
;      Update .HISTORY tag
          tagval8 = 'Exposure normalized (per sec)'     
          if (loud or i eq 0) then $
            print, 'HISTORY record updated for image',image_no,':  ',tagval8
   	  update_history,index3,tagval8
	endif else  print, '*** NO normalization because exposure (=< 0.) = ',exptime
      endif
     endif else  if loud then  $
           box_message,'Norm correction already applied, skipping...'

;  Update image index parameters if /new_avg is set:
      if (keyword_set(new_avg)) then begin
        imin = min(image3, max=imax)
        if (n_elements(image3) eq 1) then begin
          idev = 0.
          iavg = image3(0)
        endif else begin
          result = moment(image3, /double, sdev=sdev)
          iavg = float(result(0))
          idev = float(sdev)
        endelse
;    Update .HISTORY tag
        tagval9 = 'Updated img_avg, _dev, _min, _max'     
        index3.img_min = float(imin)
        index3.img_max = float(imax)
        index3.img_avg = iavg
        index3.img_dev = idev
        if (loud or i eq 0) then $
           print, 'HISTORY record updated for image',image_no,  $
                  ':  Updated img_avg, _dev, _min, _max'
        update_history,index3,tagval9
      endif
    endif							; end of calibration

; Return output image as Integer*2 unless /float is set.
    case data_chk(image3,/type) of
      2:  if (keyword_set(float))   then image3 = float(temporary(image3))
      4:  if (1-keyword_set(float)) then image3 = fix(round(temporary(image3)))
      5:  if (1-keyword_set(float)) then image3 = fix(round(temporary(image3))) else image3 = float(temporary(image3))
    endcase

; Concatenate the headers and images
    if (i eq 0) then index_out = index3 else begin
      out_str = index_out(0)
      index_out = [str_copy_tags(out_str,index_out), str_copy_tags(out_str,index3)]
    endelse
    if (i eq 0 and yes_data) then begin
      if (keyword_set(float))  then type = 4  else type = 2	; default (=2) is I*2; (=4) is float
      image_out = make_array(nx0, ny0, nimages, type=type)	; define output datacube
    endif
    if (max(image3) ne 0) then begin				; skip blank images
      if (yes_data) then begin
        if (nx gt nx0 or ny gt ny0) then begin			; if image size > datacube size
  	  image3 = rebin(temporary(image3),nx0,ny0)    		; rebin if image integral multiple of datacube
          print,'For image',image_no,':  Rebin image to smaller datacube 2D size'
        endif
        image_out(0,0,i) = image3(*,*)				; insert processed image into datacube
        if (loud or i eq 0) then print,'For image',image_no,':  Processed and Inserted into output datacube'
      endif
    endif else  print, '*** NO output of this zero image for index = ',i

  endelse						; image has elements

  systm = systime(1)
  loop_time = systm - t1
  t1 = systm
  if (loud or i eq 0) then message, /info, string('   1 image took ', loop_time, ' seconds',  $
                         format='(a,f5.1,a)')

endfor						; MAIN LOOP ends


if keyword_set(wave2point_correct) then $
     index_out=trace_wave2point(index_out)      ; apply wave dependent correct
;                                               ; to XCEN/YCEN  for latter use with
;						; Dominic Zarro's SSW mapping software. 		

; Write the optional FITS file
if (keyword_set(outtrfits)) then begin
  write_trace,index_out,image_out,outdir=outdir,prefix='tfi',/loud
endif 
if (keyword_set(outflatfits)) then begin
  write_trace,index_out,image_out,outdir=outdir,prefix='tsi',/flat_fits,/loud
endif 

run_time = systime(1)-t0
message, /info, string('Total processing time of ', run_time,' seconds for ', $  
         nimages, ' images' ,format='(a,f8.1,a,i5,a)')

if (keyword_set(qstop)) then STOP

end
