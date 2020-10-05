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

plt.ion()
for measurement in measurements:
    print('Measurement = ' + measurement)
    # Define the storage directory
    storage_measurement = os.path.join(storage, measurement)

    # Get an ordered list of files in the directory
    filelist = sorted(glob.glob(storage_measurement + '/*.jp2'))

    # Number of files
    n = len(filelist)

    # What is considered low level intensities?
    low_level = 5

    # Number of values
    n_values = 256

    # Storage
    values = np.arange(0, n_values)
    av = np.zeros((n,))
    av_above_lower_limit = np.zeros_like(av)
    time_histogram = np.zeros((n_values, n))
    x_lims = []

    # Create a histogram
    bins = -0.5 + np.arange(0, n_values+1)
    for i, f in enumerate(filelist):
        print(f, i, len(filelist))
        m = sunpy.map.Map(f)
        x_lims.append(m.date)
        time_histogram[:, i] = np.log10(np.histogram(m.data, bins)[0]/m.data.size)

        # Full average
        this_th = 10.0**time_histogram[:, i]
        av[i] = np.sum(values*this_th/np.sum(this_th))

        # Average above low level
        av_above_lower_limit[i] = np.nanmean(m.data[m.data >= low_level])

    xlims = mdates.date2num(x_lims)
    cmap = plt.get_cmap('viridis')
    cmap.set_bad(color='k', alpha=1.)
    fig, ax = plt.subplots()
    cax = ax.imshow(time_histogram, origin='lower', aspect='auto', cmap=cmap,
                    extent=[xlims[0], xlims[-1], 0, n_values-1])
    ax.plot(xlims, av, label='average', color='k')
    ax.plot(xlims, av_above_lower_limit, label='average for intensities $\geq${:s}'.format(str(low_level)), color='r')
    ax.axhline(low_level, label='lower limit={:s}'.format(str(low_level)), linestyle=':', color='k')

    # Set the x-axis to be a date
    ax.xaxis_date()
    date_format = mdates.DateFormatter('%Y-%m-%d')
    ax.xaxis.set_major_formatter(date_format)
    # This simply sets the x-axis data to diagonal so it fits better.
    fig.autofmt_xdate()

    # Set the image titles and labels
    ax.set_title('{:s}: histogram of JPEG2000 values'.format(measurement))
    ax.set_xlabel('observation time')
    ax.set_ylabel('value')

    # Include a colorbar
    cbar = fig.colorbar(cax)
    cbar.ax.set_ylabel('log10(fraction found)')
    plt.legend(framealpha=0.5)
    plt.grid('on', linestyle=':')
    plt.show()

    # Plot the fraction of low-intensity pixels
    fig, ax = plt.subplots()
    ax.xaxis_date()
    ax.xaxis.set_major_formatter(date_format)
    fig.autofmt_xdate()
    for jpeg_value in range(0, low_level):
        ax.plot(xlims, time_histogram[jpeg_value, :], label='level={:s}'.format(str(jpeg_value)))

    # Set the image titles and labels
    ax.set_title('Fractions found for low intensities'.format(measurement))
    ax.set_xlabel('observation time')
    ax.set_ylabel('log10(fraction found)')
    plt.grid('on', linestyle=':')
    plt.legend()
    plt.show()
