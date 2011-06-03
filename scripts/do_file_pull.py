import hvPull,sys,datetime

# Get the configuration files as arguments
info = hvPull.Config([sys.argv[1],sys.argv[2]])
#print(info.observations)
# define the directories that we will look at
# while True:
directories = hvPull.Directories(info,datetime.datetime.utcnow())
print(directories)
# Query the location and download the data
# put this inside the while loop
#hvPull.Get(info,directories)

