Rural Roads
===========
This is an attempt to categorize Road Policing spatial data with an urban/rural classification from Statistics New Zealand.

Statistics New Zealand produced an unofficial [categorisation](http://www.stats.govt.nz/browse_for_stats/people_and_communities/Geographic-areas/urban-rural-profile-update.aspx) of the 2006 Census Meshblock dataset into:

* Area outside urban/rural profile
* Highly rural/remote area
* Independent Urban Area
* Main urban area
* Rural area with high urban influence
* Rural area with low urban influence
* Rural area with moderate urban influence
* Satellite Urban Area

How to Use
----------
1. Download the data as explained in the "Data" section.
1. Install the system requirements as explained in the "System Requirements" section.
1. Set up a PostGIS database and run the queries as explained in the "PostGIS" section.

Data
----

The 2006 Census Meshblock dataset is available as [shapefiles](http://www3.stats.govt.nz/digitalboundaries/census/NZ_L2_2006_NZTM_ArcShp.zip). Download with:
```
# 2006 Census Meshblock
mkdir data/meshblocks
cd meshblocks
wget http://www3.stats.govt.nz/digitalboundaries/census/NZ_L2_2006_NZTM_ArcShp.zip
unzip NZ_L2_2006_NZTM_ArcShp.zip
rm NZ_L2_2006_NZTM_ArcShp.zip
```

The Urban/Rural Profile Geographic Concordance is available as a [.xls](http://www.stats.govt.nz/~/media/Statistics/browse-categories/people-and-communities/geographic-areas/urban-rural-profile-update/concordance-2006.xls).  The meshblocks can be [aggregated](http://www.stats.govt.nz/browse_for_stats/people_and_communities/Geographic-areas/geographic-area-files.aspx#2006) into larger areas.  Note that the Urban/Rural Profile Geographic Concordance and the Geographic Area File include 30 meshblocks that are not in the shapefile.  None of the 30 missing meshblocks are the mainlaind:

* Oceanic-Kermadec Islands
* Kermadec Islands
* Oceanic-Oil Rigs Taranaki
* Chatham Islands
* Oceanic-Chatham Islands
* Oceanic-Campbell Island
* Campbell Island
* Oceanic-Oil Rig Southland
* Oceanic-Auckland Islands
* Auckland Islands
* Ross Dependency
* NZ Economic Zone
* Oceanic-Bounty Islands
* Bounty Islands
* Oceanic-Snares Islands
* Snares Island
* Oceanic-Antipodes Islands
* Antipodes Islands



LINZ provides road centrelines, coastlines and coast polygons from their [data service](http://data.linz.govt.nz/).  Machine-machine downloads can be arranged from [here](http://data.linz.govt.nz/p/web-services/) but downloading with wget/curl doesn't work due to authentication.

Crashes are from NZTA CAS (Crash Analysis System) and are [freely redistributable](./docs/CAS_licence.eml).  CAS documentation says the projection is NZMG, but it seems to be NZTM.  Remove extraneous comma before header `"EASTING"`.  Add `,"NOTHING"` to the end of the first line.

Police boundaries are from Koordinates.  Machine-machine downloads are planned.

Road centrelines (at 1:500k and 1:50k, also available at 1:250k), coastline and coast polygons are from the LINZ Data Service.

Census data is from Statistics New Zealand.
```
cd data
axel -n 10 http://www3.stats.govt.nz/meshblock/2006/access/CensusData.zip
unzip CensusData.zip
mv CensusData.zip ../
```

Helpful Docs
------------
[Dealing with non-unique polygon IDs](https://stat.ethz.ch/pipermail/r-sig-geo/2009-May/005666.html): can a meshblock have several polygons?  Possibly groups of islands?  Doesn't work anyway. [gBuffer](http://stackoverflow.com/questions/13662448/what-does-the-following-error-mean-topologyexception-found-non-nonded-intersec) did.  [More here](https://stat.ethz.ch/pipermail/r-sig-geo/2012-December/016952.html).

[PROJ.4 CRS strings for NZTM and NZMG](http://gis.stackexchange.com/questions/20389/converting-nzmg-or-nztm-to-latitude-longitude-for-use-with-r-map-library/20401#20401):
* NZTM: `+proj=tmerc +lat_0=0.0 +lon_0=173.0 +k=0.9996 +x_0=1600000.0 +y_0=10000000.0 +datum=WGS84 +units=m` (not really WGS84 but close)
* NZMG: `+proj=nzmg +lat_0=-41.0 +lon_0=173.0 +x_0=2510000.0 +y_0=6023150.0 +ellps=intl +units=m` plus a transformation that might be `+towgs84=59.47,-5.04,187.44,0.47,-0.1,1.024,-4.5993`
(NZGD2000 isn't really WGS84, but close enough)

System Requirments
------------------

### Session Info
```
> sessionInfo()
R version 3.0.1 (2013-05-16)
Platform: x86_64-pc-linux-gnu (64-bit)

locale:
 [1] LC_CTYPE=en_US.UTF-8 LC_NUMERIC=C         LC_TIME=C           
 [4] LC_COLLATE=C         LC_MONETARY=C        LC_MESSAGES=C       
 [7] LC_PAPER=C           LC_NAME=C            LC_ADDRESS=C        
[10] LC_TELEPHONE=C       LC_MEASUREMENT=C     LC_IDENTIFICATION=C 

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] reshape2_1.2.2     lubridate_1.3.0    ggplot2_0.9.3.1    scales_0.2.3      
 [5] RColorBrewer_1.0-5 maptools_0.8-25    lattice_0.20-15    foreign_0.8-54    
 [9] rgdal_0.8-10       rgeos_0.2-19       sp_1.0-11          plyr_1.8          

loaded via a namespace (and not attached):
 [1] MASS_7.3-26      colorspace_1.2-2 dichromat_2.0-0  digest_0.6.3    
 [5] gtable_0.1.2     labeling_0.2     munsell_0.4      proto_0.3-10    
 [9] stringr_0.6.2    tools_3.0.1   
 ```

### rgeos and rgdal
rgdal requires the (non-R) GIS packages GDAL and PROJ.4.  These would be painful to install were it not for the UbuntuGIS ppa:

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update

# GDAL
sudo apt-get install gdal-bin libgdal-dev libgdal1 libgdal1-dev # not sure how many of these are necessary

# PROJ.4
sudo apt-get install proj proj-bin proj-data libproj-dev libproj0

```
### maptools, mapproj and PBSmapping
May also require GDAL and PROJ.4 as above

### RODBC (r package) and mdbtools (linux package)
For connecting to a Microsoft Access .mdb database for meshblock demographics from Stats NZ.  See section "Census Data" below, but basically this doesn't work yet.  Instead it has been done with MS Access, and a dataset saved in data/censusData.txt.

```
sudo apt-get install mdbtools
```
```
install.packages("RODBC")
```

Regions
-------
```
> levels(meshblocks@data$RC06D)
 [1] "Area Outside Region"      "Auckland Region"         
 [3] "Bay of Plenty Region"     "Canterbury Region"       
 [5] "Gisborne Region"          "Hawke's Bay Region"      
 [7] "Manawatu-Wanganui Region" "Marlborough Region"      
 [9] "Nelson Region"            "Northland Region"        
[11] "Otago Region"             "Southland Region"        
[13] "Taranaki Region"          "Tasman Region"           
[15] "Waikato Region"           "Wellington Region"       
[17] "West Coast Region"
```

Crash Tables
------------

Each table is named with by its region, followed by a description, e.g. BoP-coordinates.txt

### BoP-coordinates.txt
* ...
* CRASH ID
* ...
* EASTING
* NORTHING

### BoP-crashes.txt
* state highway
* severity f/s/m/n
* day
* month
* year
* hour
* crashid

### BoP-drivers.txt
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
* role
* driver causes
* driver cause categories

exclude uninjured people? No

### BoP-victims
* dvr/pass/other
* sex
* age
* injury
* role
* driver at fault
* ethnicity

exclude uninjured people? No

PostGIS
-------
[Installation](http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS20Ubuntu1204).  If you have already added the ubuntu-gis unstable ppa you'll have to remove it.
```
sudo add-apt-repository -r ppa:ubuntugis/ubuntugis-unstable
```
Then proceed with the installation instructions.
```
sudo apt-get install python-software-properties # you may already have this if you installed gdal etc.
sudo apt-add-repository ppa:ubuntugis/ppa
sudo apt-get update
sudo apt-get install postgresql-9.1-postgis
```
Set up the acccounts
```
$ sudo passwd postgres
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
$ sudo -s -u postgres
postgres$ psql
psql (9.1.3)
Type "help" for help.

postgres=# \password postgres
Enter new password: 
Enter it again: 
postgres=# \q
postgres$ 
```
Make it easier for yourself
```
postgres$ createuser --superuser $USER     ---- note: createuser is a command line tool to create a PostgreSQL user, not a system account  
postgres$ createdb $USER
postgres$ psql
psql (9.1.3)
Type "help" for help.

postgres=# \password $USER
Enter new password: 
Enter it again: 
postgres=# \q
postgres$ exit
$USER$ psql
psql (9.1.3)
Type "help" for help.
$USER=#                        ---- voila! 
```
Create a database (from the ordinary command line)
```
createdb ruralRoads
psql ruralRoads
ruralRoads=# CREATE EXTENSION postgis;
CREATE EXTENSION
ruralRoads=# \q
```
Back at the command line, push shapefiles into the database.
```
shp2pgsql data/meshblocks/MB06_LV2 meshblocks ruralRoads | psql -d ruralRoads
shp2pgsql data/roads/nz-mainland-road-centreli/nz-mainland-road-centreli roads ruralRoads | psql -d ruralRoads
shp2pgsql data/police_boundaries/nz-police-district-bounda/nz-police-district-bounda districts ruralRoads | psql -d ruralRoads
shp2pgsql data/police_boundaries/nz-police-area-boundaries/nz-police-area-boundaries areas ruralRoads | psql -d ruralRoads
shp2pgsql data/police_boundaries/nz-police-station-boundar/nz-police-station-boundar stations ruralRoads | psql -d ruralRoads
```

Index
```
psql ruralRoads
# in the psql prompt:
CREATE INDEX i_meshblocks_geom ON meshblocks USING GIST ( geom );
CREATE INDEX i_roads_geom ON roads USING GIST ( geom );
CREATE INDEX i_districts_geom ON districts USING GIST ( geom );
CREATE INDEX i_areas_geom ON areas USING GIST ( geom );
CREATE INDEX i_stations_geom ON stations USING GIST ( geom );
\q
```
Queries, most of which are too long to execute in the shell.  Frame the "psql" commands below inside a system() command in an R script, e.g.
```
system("psql -f sql/totalRoadLength.sql ruralRoads > output/totalRoadLength.txt")
```
```
# Total road length
psql -f sql/totalRoadLength.sql ruralRoads > output/totalRoadLength.txt
# That was total road length within meshblocks, which should be exactly the same
# as the sum of the following query, road length by meshblock.  Use it for 
# validation.  Note: road length does not include state highways, highway length
# includes state highways only.
psql -f sql/roadLengthByMeshblock.sql ruralRoads -tA -F ',' > output/roadLengthByMeshblock.csv
psql -f sql/highwayByMeshblock.sql ruralRoads -tA -F ',' > output/highwayByMeshblock.csv
# meshblock areas
psql -f sql/areaByMeshblock.sql ruralRoads -tA -F ',' > output/areaByMeshblock.csv
# meshblock police regions (district, area, station)
psql -f sql/meshblockDistrict.sql ruralRoads -tA -F ',' > output/meshblockDistrict.csv
psql -f sql/meshblockArea.sql ruralRoads -tA -F ',' > output/meshblockArea.csv
psql -f sql/meshblockStation.sql ruralRoads -tA -F ',' > output/meshblockStation.csv
```

Census Data
-----------
The PostgreSQL method below is a grade A pain that doesn't yet work.  Try the mdb2sqlite script.
```
sudo apt-get install sqlite3
sh mdb2sqlite data/CensusData.mdb censusData.sq3
```

Using mdbtools (mdb-schema, mdb-export) dump data from CensusData.mdb into a new PostgreSQL database.  You need probably 8GB of disk space to do this, so try an EC2 instance with that much larger a root volume.

```
createdb censusData
mdb-schema data/CensusData.mdb postgres | psql -d censusData
# get a list of tables with
mdb-tables data/CensusData.mdb
# then for each table
echo "\set QUIET" > censusData.sql
echo "BEGIN; LOCK TABLE tblCountsAreaUnit; " >> censusData.sql
mdb-export -I postgres -q \' -R "\n" data/CensusData.mdb tblCountsAreaUnit >> censusData.sql
echo "COMMIT;" >> censusData.sql
psql -d censusData -f censusData.sql

tblCountsAreaUnit 
tblCountsMeshBlock 
tblCountsNewZealand 
tblCountsRegionalCouncil 
tblCountsTerritorialAuthority 
tblGeogAreaUnit 
tblGeogMeshBlock 
tblGeogRegionalCouncil 
tblGeogTerritorialAuthority 
tblGeogWard 
tblQuestions 
tblSurveys 
tblCountsWard
```
