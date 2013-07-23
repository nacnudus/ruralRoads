require(rgeos)
require(rgdal)
require(plyr)
require(ggplot2)
require(maps)

# Global
setwd("..")


# Load Data
############

# Coastline (police boundaries exceed the coastline)
coast <- readOGR("/home/nacnudus/R/rural_roads/data/Coastline/", "nz-mainland-coastlines-to")

# stations boundaries
stations <- readOGR("/home/nacnudus/R/rural_roads/data/PoliceBoundaries/nz-police-station-boundar/", "nz-police-station-boundar")

# 123-person stations
x123 <- read.table(
  file("/home/nacnudus/R/rural_roads/data/123.txt")
  , header = FALSE
  , sep = "\t"
)

# Clean Data
############

colnames(x123) <- c("STATION_NA", "AREA_NAME", "DISTRICT_N")
# x123 lacks a field to say "rural" because they all are rural, but one is necessary.
x123$rural <- TRUE

# Do
####

# work out labels
stationLabels <- as.data.frame(gCentroid(stations,byid=TRUE)@coords)
stationLabels$label <- stations@data$STATION_NA

# join stations and x123 concordance
stations@data <- join(stations@data, x123[, c("STATION_NA", "rural")], by = "STATION_NA")
stations@data[is.na(stations@data$rural), "rural"] <- FALSE

# colour
stations@data$colour[stations@data$rural == TRUE] <- "grey"
stations@data$colour[stations@data$rural == FALSE] <- "white"

# plot and save
png("myplot.png", width=10, height=10, units="in", res=600)
plot(stations, col = stations@data$colour, lwd = 0.2)
plot(coast, add = TRUE, lwd = 0.2, col = "dark red")
text(stationLabels$x, stationLabels$y, labels = stationLabels$label, cex = 0.2)
dev.off()