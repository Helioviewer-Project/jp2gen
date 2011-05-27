import hvPull,sys,datetime

# Get the configuration files as arguments
info = hvPull.Config([sys.argv[1],sys.argv[2]])
print info.observations
print info.ingestion

# define the directories that we will look at
# while True:
#directories = hvPull.Directories(data,local,datetime.datetime.utcnow())

# Query the location and download the data
# put this inside the while loop
#hvPull.Get(data,local,directories)

