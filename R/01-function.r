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
  mrs <- subset(meshblocks, meshblocks@data$code <= x)
  # shake everything up a bit to prevent any non-noded intersections errors
  mrs <- gBuffer(mrs, width=0, byid=TRUE)
  # union all polygons in each one to speed up plotting
  mrs <- unionSpatialPolygons(mrs, rep(1, length(mrs@polygons)))
  return(mrs)
}


# load crashes ------------------------------------------------------------

# subsets crashes by ruralness once they've been loaded and cleaned,
# generally called within loadCrashes function e.g.
# dlply(urban.rural, .(code), function(x) (subsetCrashes(x$code))))
subsetCrashes <- function(x, y) {
  # "crs" stands for "crashes rural subset"
  crs <- gIntersection(x, meshblocks[[y]])
}

# given a filename (x), loads and cleans crashes ready for subsetting by 
# ruralness
loadCrashes <- function(x) {
  crashes <- read.csv(x, quote = "\"")
  crashes <- crashes[, c("CRASH.ID", "EASTING", "NORTHING")]
  colnames(crashes) <- c("id", "easting", "northing")
  crashes <- SpatialPointsDataFrame(coords = crashes[, 2:3], data=crashes)
  proj4string(crashes) <- projectionString # same crs as everything else
  crashes
}
