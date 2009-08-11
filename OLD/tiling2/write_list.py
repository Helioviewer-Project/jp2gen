
import sys, os, fnmatch

def locate(pattern, root=os.curdir, save = 'output.txt'):
    '''Locate all files matching supplied filename pattern in and below
    supplied root directory.'''
    print 'Search for files ' + pattern + ' in ' + root
    L = []
    for path, dirs, files in os.walk(os.path.abspath(root)):
        for filename in fnmatch.filter(files, pattern):
            #L.append(os.path.join(path, filename))
            L.append(filename)
    log = open( save, 'w')
    print 'Saving list of files to ' + save
    for line in L:
        log.write(line + '\n')
    log.close()
    return L


def hv_write_img_list(yyyy,mm,instrument,observation, hvroot, pattern):
    imgroot = hvroot + 'img/'
    lisroot = hvroot + 'txt/'

    root = imgroot + instrument + '/' + yyyy + '/' + mm + '/'
    save = lisroot + instrument + '/' + yyyy + '_' + mm + '_' + instrument + '_' + observation + '.txt'
    locate(pattern,root = root, save = save)

#
# save lists of all the files
#

for month in range(1,13):
    mm = "%02d" % (month)
    # eit images
    hv_write_img_list('2003',mm,'eit','000','/Users/ireland/hv/','*.sav')
    
    # lasco c2 regular
    hv_write_img_list('2003',mm,'las','reg_C2','/Users/ireland/hv/','*C2_regular.sav')
    # lasco c3 regular
    hv_write_img_list('2003',mm,'las','reg_C3','/Users/ireland/hv/','*C3_regular.sav')
    
    # lasco c2 huw morgan processed
    hv_write_img_list('2003',mm,'las','huw_C2','/Users/ireland/hv/','*C2.sav')
    
    # lasco c3 huw morgan processed
    hv_write_img_list('2003',mm,'las','huw_C3','/Users/ireland/hv/','*C3.sav')

