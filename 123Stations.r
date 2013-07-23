require(rgeos)
require(rgdal)
require(plyr)
require(ggplot2)

# Load Data
############

# shapefiles
stations <- readOGR("/home/nacnudus/R/rural_roads/data/PoliceBoundaries/nz-police-station-boundar/", "nz-police-station-boundar")

# 123-person stations
x123 <- read.table(
  file("/home/nacnudus/R/rural_roads/data/123.txt")
  , header = FALSE
  , sep = "\t"
)
colnames(x123) <- c("STATION_NA", "AREA_NAME", "DISTRICT_N")
# x123 lacks a field to say "rural" because they all are rural, but one is necessary.
x123$rural <- TRUE

# join stations and x123 concordance
stations@data <- join(stations@data, x123[, c("STATION_NA", "rural")], by = "STATION_NA")
stations@data[is.na(stations@data$rural), "rural"] <- FALSE

# prepare to plot
f.stations <- fortify(stations, region = "STATION_NA") # "region" sets the "id"