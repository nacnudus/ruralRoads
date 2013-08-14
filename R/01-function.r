require(plyr)
require(rgeos) # gBuffer
require(rgdal) # readOGR
require(maptools) # unionSpatialPolygons
# require(mapproj) # commented out to test necessity
# require(plyr) # commented out to test necessity
require(RColorBrewer) # brewer.pal
require(scales) # for transparency in base graphics
require(ggplot2)

projectionString <- "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +units=m +no_defs"
# you can get this from any of the spatial objects with proj4string()
# currently it is New Zealand Transverse Mercator (NZTM)

# subset highways ---------------------------------------------------------

# TODO highway length per meshblock in PostGIS
subsetHighways <- function(x) {
  subset(x, !is.na(x@data$hway_num))
}


# subset and union meshblock polygons by ruralness ------------------------

# x is a row of the urban.rural lookup table, e.g.
# ddply(urban.rural, .(code), function(x) (x$code))
# so call this function like
# dlply(urban.rural, .(code), function(x) (subsetMeshblock(x$code)))

subsetMeshblock <- function(x) {
  # "mrs" stands for "meshblocks rural subset"
  mrs <- subset(meshblocks, meshblocks@data$code == x)
  # shake everything up a bit to prevent any non-noded intersections errors
  mrs <- gBuffer(mrs, width=0, byid=TRUE)
  # union all polygons in each one to speed up plotting
  mrs <- unionSpatialPolygons(mrs, rep(1, length(mrs@polygons)))
  return(mrs)
}


# load crashes ------------------------------------------------------------

# given a filename (x), loads and cleans crashes ready for subsetting by 
# ruralness
loadCrashes <- function(x) {
  # remove extraneous comma before header `"EASTING"` and append `,"NOTHING"` 
  # to the end of the first line.
  fixedFile <- paste(x, ".fix", sep = "")
  sed <- paste("sed 's/,,\"EASTING\",\"NORTHING\"/,\"EASTING\",\"NORTHING\",\"NOTHING\"/' <"
               , x, ">", fixedFile)
  system(sed)
  # read
  crashes <- read.csv(fixedFile, quote = "\"")
  crashes <- crashes[!is.na(crashes$NORTHING)
                     , c("CRASH.ID", "EASTING", "NORTHING")]
  colnames(crashes) <- c("id", "easting", "northing")
  crashes <- SpatialPointsDataFrame(coords = crashes[, 2:3], data=crashes)
  proj4string(crashes) <- projectionString # same crs as everything else
  return(crashes)
}
