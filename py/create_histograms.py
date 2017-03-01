#
# Create histograms of
#
import os
import glob
import numpy as np
import matplotlib.pyplot as plt
import sunpy.map
import matplotlib.dates as mdates

measurements = ['304'] #, '131', '171', '193', '211', '304', '335', '1600', '1700', '4500']
storage = os.path.expanduser('~/Data/hvp/aia_color_correction')


for measurement in measurements:
    print('Measurement = ' + measurement)
    # Define the storage directory
    storage_measurement = os.path.join(storage, measurement)

    # Get an ordered list of files in the directory
    filelist = sorted(glob.glob(storage_measurement + '/*.jp2'))

    # Number of files
    n = len(filelist)

    # Storage
    time_histogram = np.zeros((256, n))
    x_lims = []
    # Create a histogram
    for i, f in enumerate(filelist):
        print(f, i, len(filelist))
        m = sunpy.map.Map(f)
        x_lims.append(m.date)
        for p in range(0, 256):
            time_histogram[p, i] = np.log10(np.sum(m.data[:, :] == p))

    xlims = mdates.date2num(x_lims)
    cmap = plt.get_cmap('bwr')
    cmap.set_bad(color='k', alpha=1.)
    fig, ax = plt.subplots()
    ax.imshow(time_histogram, origin='lower', aspect='auto', cmap=cmap,
              extent=[xlims[0], xlims[1], 0, 255])
    ax.xaxis_date()
    date_format = mdates.DateFormatter('%Y-%m-%d')
    ax.xaxis.set_major_formatter(date_format)
    # This simply sets the x-axis data to diagonal so it fits better.
    fig.autofmt_xdate()

    plt.colorbar()
    plt.show()
