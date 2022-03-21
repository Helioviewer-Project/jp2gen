jp2gen/trace
==========

Code to convert TRACE FITS data to JPEG2000 for use with the Helioviewer Project.
For questions/comments, please contact dzarro@sesda.com or Jack.Ireland@nasa.gov

-------------------
Requirements
-------------------
- IDL version 8.5 or later
- Git installed on your local system
- Local directories for ssw and sswdb
- A sswidl.bat batch file on your local system which will look something like the following:

set SSW=C:\Users\jltsang\dev\ssw

set SSWDB=C:\Users\jltsang\dev\sswdb

set IDL_STARTUP=%SSW%\gen\idl\ssw_system\idl_startup_windows.pro

set SSW_INSTR=trace helioviewer

set IDL_DIR=C:\Program Files\Exelis\IDL85

cd %CD%

set IDL_EXE="%IDL_DIR%"\bin\bin.x86_64
start "" %IDL_EXE%\idlde.exe   

--------------------
Updating before use
--------------------
In order to upgrade ssw to the latest for use in TRACE, use the following commands

IDL> ssw_upgrade,/trace,/spawn
IDL> sswdb_upgrade,/trace,/spawn
IDL> .reset

--------------------------------------------------------

You will also need code from jp2gen to be updated in-order to run the conversion.
To bring-in code from the jp2gen github repository onto your local system use this on your console:

git clone https://github.com/Helioviewer-Project/jp2gen.git

Afterwards, to pull in the latest updates to the github code, you can use:

git fetch --all
git pull
-------------------
Database
-------------------

The trace conversion routine will automatically look through https://sdac.virtualsolar.org/cgi/search 
for TRACE files that match start/end time input, and wavelength.
However, you can also download TRACE fits files onto your local system from:

https://helioviewer.org/jp2/TRACE/

-------------------
Instructions for use
-------------------

To find all Level 0 trace fits files on the remote archive between a start time and end time range, use the following:

IDL> hv_trace_test,'1-may-09 10:00','1-may-09 23:00'

A widget that contains the list of found fits files for all wavelengths and within input time range will appear.
Select the desired fits file, or use shift and controls keys to select multiple files. Press 'accept' and the selected
file(s) will be converted into .jp2 files and placed in your current directory. IDL will also plot the last file selected
---------------------------------------------------------
To return fits files for only one date, you may also use just one time start input:

IDL> hv_trace_test,'1-may-01'

The same widget as before will appear where you may select file(s)
---------------------------------------------------------
If you want to select fits files for a certain day and at a specific wavelength, you may input wavelength as showwn:

IDL> hv_trace_test,'1-may-01', wavelength=171

The same widget will appear, but you will notice that only fits files with the requested wavelength appear

---------------------------------------------------------
You may also add a keyword that finds and processes/preps a TRACE file nearest the input time:

IDL> hv_trace_test,'1-may-09 22:00',/nearest,wavelength=195

This will plot the image, and create the jp2 file without the selection widget. 