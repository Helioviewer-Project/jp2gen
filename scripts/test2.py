import hvPull
import sys

data, local = hvPull.ReadConfig(sys.argv[1],sys.argv[2])

print data, local
