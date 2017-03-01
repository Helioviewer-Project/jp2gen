#
# Download a set of jp2 files from helioviewer
#
import os
import datetime
import astropy.units as u
from sunpy.time import parse_time
from sunpy.net.helioviewer import HelioviewerClient

cadence = 1 * u.year
start_time = parse_time('2010/10/01')
end_time = parse_time('2017/02/01')

hv = HelioviewerClient()
observatory = 'SDO'
instrument = 'AIA'
detector = 'AIA'
measurements = ['94', '131', '171', '193', '211', '335', '1600', '1700', '4500']
measurements = ['304']

storage = os.path.expanduser('~/Data/hvp/aia_color_correction')
if not os.path.isdir(storage):
    os.makedirs(storage)


for measurement in measurements:
    # Make the storage directory
    storage_measurement = os.path.join(storage, measurement)
    if not os.path.isdir(storage_measurement):
        os.makedirs(storage_measurement)

    today = start_time
    while today <= end_time:
        # Get the next file
        filepath = hv.download_jp2(today, observatory=observatory,
                                   instrument=instrument, detector=detector,
                                   measurement=measurement)

        # Move the file to the storage location
        _dummy, filename = os.path.split(filepath)
        os.rename(filepath, os.path.join(storage_measurement, filename))
        today += datetime.timedelta(seconds=cadence.to(u.s).value)
