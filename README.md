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

The 2006 Census Meshblock dataset is available as shapefiles in both [NZTM](http://www3.stats.govt.nz/digitalboundaries/census/NZ_L2_2006_NZTM_ArcShp.zip) and [NZMG](http://www3.stats.govt.nz/digitalboundaries/census/NZ_L2_2006_NZMG_ArcShp.zip) projections.

The Urban/Rural Profile Geographic Concordance is available as a [.xls](http://www.stats.govt.nz/~/media/Statistics/browse-categories/people-and-communities/geographic-areas/urban-rural-profile-update/concordance-2006.xls).

An [aggregation](http://www.stats.govt.nz/browse_for_stats/people_and_communities/Geographic-areas/geographic-area-files.aspx#2006) into larger areas.

Helpful Docs
------------
[Dealing with non-unique polygon IDs](https://stat.ethz.ch/pipermail/r-sig-geo/2009-May/005666.html): can a meshblock have several polygons?  Possibly groups of islands?  Doesn't work anyway. [This (gBuffer)](http://stackoverflow.com/questions/13662448/what-does-the-following-error-mean-topologyexception-found-non-nonded-intersec) did.  [More here](https://stat.ethz.ch/pipermail/r-sig-geo/2012-December/016952.html).

[Merging spatial datasets](http://rpubs.com/PaulWilliamson/6577) (see System Requirments): uses readOGR, which is apparently a more general and tolerant alternative to readShapePoly.

[PROJ.4 CRS strings for NZTM and NZMG](http://gis.stackexchange.com/questions/20389/converting-nzmg-or-nztm-to-latitude-longitude-for-use-with-r-map-library/20401#20401)

System Requirments
------------------
* rgeos and rgdal.  rgdal requires the (non-R) GIS packages GDAL and PROJ.4.  These would be painful to install were it not for the UbuntuGIS ppa:

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update

# GDAL
sudo apt-get install gdal-bin libgdal-dev libgdal1 libgdal1-dev # not sure how many of these are necessary

# PROJ.4
sudo apt-get install proj proj-bin proj-data libproj-dev libproj0

```
* maptools and mapproj, which may also require GDAL and PROJ.4 as above