require(plyr)
require(rgeos) # gBuffer
require(rgdal) # readOGR
require(maptools) # unionSpatialPolygons
# require(mapproj) # commented out to test necessity
# require(plyr) # commented out to test necessity
require(RColorBrewer) # brewer.pal
require(scales) # for transparency in base graphics
require(ggplot2)


# global variables --------------------------------------------------------

projectionString <- "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +units=m +no_defs"
# you can get this from any of the spatial objects with proj4string()
# currently it is New Zealand Transverse Mercator (NZTM)

# urban rural lookup
urbanRural <- data.frame(urbanRuralGrade = c("Main urban area"
                                        , "Independent Urban Area"
                                        , "Satellite Urban Area"
                                        , "Rural area with high urban influence"
                                        , "Rural area with moderate urban influence"
                                        , "Rural area with low urban influence"
                                        , "Highly rural/remote area"
                                        , "Area outside urban/rural profile")
                         , code = c(LETTERS[1:7], "Z")
                         , urbanRural = c(rep("urban", 3), rep("rural", 4), NA))


# subset highways ---------------------------------------------------------

# TODO highway length per meshblock in PostGIS
subsetHighways <- function(x) {
  subset(x, !is.na(x@data$hway_num))
}


# subset and union meshblock polygons by ruralness ------------------------

# x is a row of the urbanRural lookup table, e.g.
# ddply(urbanRural, .(code), function(x) (x$code))
# so call this function like
# dlply(urbanRural, .(code), function(x) (subsetMeshblock(x$code)))

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

# given a filename (x) of a CAS crash list with map coordinates, loads
# crashes into a SpatialPointsDataFrame
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
  colnames(crashes) <- c("crashID", "easting", "northing")
  crashes <- SpatialPointsDataFrame(coords = crashes[, 2:3], data=crashes)
  proj4string(crashes) <- projectionString # same crs as everything else
  return(crashes)
}


# join crashes to meshblocks ----------------------------------------------

# given the output of loadCrashes (x), and a filename (y), matches crashes
# to meshblocks and saves the resulting data frame

joinCrashesMeshblocks <- function(x, y) {
  ID <- over(x , meshblocks)
  crashMeshblocks <- data.frame(cbind(x@data$crashID, ID[, "meshblockID"]))
  colnames(crashMeshblocks) <- c("crashID", "meshblockID")
  crashMeshblocks$meshblockID <- as.character(crashMeshblocks$meshblockID)
  write.table(crashMeshblocks
              , row.names = FALSE
              , col.names = c("crashID", "meshblockID")
              , file = y)
  return(crashMeshblocks)
}
