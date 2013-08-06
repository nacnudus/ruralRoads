require(rgeos) # gBuffer
require(rgdal) # readOGR
require(maptools) # unionSpatialPolygons
# require(mapproj) # commented out to test necessity
# require(plyr) # commented out to test necessity
require(RColorBrewer) # brewer.pal
require(scales) # for transparency in base graphics


# code to load crashes from .csv
crashes <- read.csv("data/BoPCoordinates.csv", quote = "\"")


# subset highways ---------------------------------------------------------

subsetHighways <- function(x) {
  subset(x, !is.na(x@data$hway_num))
}