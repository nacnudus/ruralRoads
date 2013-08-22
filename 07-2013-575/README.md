07-2013-575
===========
Bay of Plenty drink-driving
---------------------------

This is an analysis of alcohol-related crashes in the Bay of Plenty district.

It only uses so much code as will identify the meshblock each crash took place in and what urban/rural category that meshblock is.  Meshblock and urban/rural concordance data is sourced from ruralRoads/data.  Data specific to this analysis, i.e. crashes (from CAS), is in the data directory within this analysis.  R code is in the R directory within this analysis.

Initialize from a new instance in Amazon EC2.
---------------------------------------------

In the shell:
```
cd R
git clone https://github.com/nacnudus/ruralRoads
```

In RStudio:
```
setwd("~/R/ruralRoads/07-2013-575")
source("R/01-function.r")
source("R/02-load.r")
source("R/03-clean.r")
```
Then start doing your analysis, perhaps in R/04-do.r.

Further work is needed to get the spatial data, which you only need to do for calculating a new district, say, of meshblocks and crashes.

In the shell, in the R directory:
```
# Get a copy of spatialData.Rdata, which will overwrite the data/ and output/
# directories.
rm -r data output # make sure you're not deleting your only copy of anything
sudo chmod 600 nacnudus # you need the password
# This is only an example.  You'll need an actual address where data.zip lives.
scp -i nacnudus ec2-54-215-134-162.us-west-1.compute.amazonaws.com:/home/nacnudus/R/ruralRoads/data.zip ./
unzip data.zip
```

If you ever need to add something to the zip file (say, you've saved a new spatial object into output/spatialData.Rdata), then you can remove old copies of things via the shell with `zip -d data.zip my/old.file` and add new stuff in with `zip -g data.zip my/new.file`.  To add whole directories, use the recursion flag, e.g. `zip -g -r data.zip my/new/directory/`.


CAS Data
--------
This was last pulled from CAS on 14 August 2013.

Each table is named with by its region, followed by a description, e.g. BoP-coordinates.txt

### BoP-coordinates.txt
* ...
* CRASH ID
* ...
* EASTING
* NORTHING

### BoP-crashes.txt
* crashID
* state highway
* severity f/s/m/n
* day
* month
* year
* hour
* crashid

### BoP-drivers.txt
* crashID
* sex
* age
* injury
* role
* driver at fault
* driver license type
* driver overseas type
* ethnicity

exclude uninjured people? No

### BoP-drivers-causes.txt
* crashID
* role
* driver causes
* driver cause categories

exclude uninjured people? No

### BoP-victims
* crashID
* dvr/pass/other
* sex
* age
* injury
* role
* driver at fault
* ethnicity
