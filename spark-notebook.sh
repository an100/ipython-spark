#!/bin/bash

# Strict mode
set -euo pipefail
IFS=$'\n\t' 

# Create a self signed certificate for the user if one doesn't exist
if [ ! -f $PEM_FILE ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $PEM_FILE -out $PEM_FILE \
    -subj "/C=XX/ST=XX/L=XX/O=dockergenerated/CN=dockergenerated"
fi

# Create the hash to pass to the IPython notebook, but don't export it so it doesn't appear
# as an environment variable within IPython kernels themselves
HASH=$(python3 -c "from IPython.lib import passwd; print(passwd('${PASSWORD}'))")
unset PASSWORD

#ipython2 notebook --no-browser --port 8888 --ip=* --certfile=$PEM_FILE --NotebookApp.password="$HASH"
export PYSPARK_PYTHON=ipython2
export PYSPARK_SHELL=1
export IPYTHON_OPTS="notebook --no-browser --port 8888 --ip=* --certfile=$PEM_FILE --NotebookApp.password=\"$HASH\""

/spark/bin/pyspark 
