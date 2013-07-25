require(rgeos)
require(rgdal)
require(maptools)
require(mapproj)
require(plyr)
require(ggplot2)

# Global
setwd("/home/nacnudus/R/ruralRoads")

# Load
######

# Coastline for context and because police boundaries exceed it
coast <- readOGR("data/Coastline/", "nz-mainland-coastlines-to")

# Districts, Areas, Stations
districts <- readOGR("data/PoliceBoundaries/nz-police-district-bounda/", "nz-police-district-bounda")
areas <- readOGR("data/PoliceBoundaries/nz-police-area-boundaries/", "nz-police-area-boundaries")
stations <- readOGR("data/PoliceBoundaries/nz-police-station-boundar/", "nz-police-station-boundar")

# urban/rural concordance
concordance <- read.csv(
  file("data/concordance-2006.csv")
  , header = TRUE
  , colClasses = c("numeric", "factor", "factor")
)

# Clean
#######

# convert coast from spatialLines to spatialPolygons
coastPolySet <- SpatialLines2PolySet(coast)
coastPolygons <- PolySet2SpatialPolygons(coastPolySet)
# not pretty and not for plotting, just for trimming the districts
districts2 <- gIntersection(districts, coastPolygons, byid = TRUE)

colnames(concordance) <- c("MB06", "urban.rural", "main.urban.area")
# later, "MB06" has to be "id" so it can be joined to the polygons.
# trouble is, sometimes has to be factor, sometimes character.  TODO.

# aggregations into larger areas
# prepare column headings and classes
area.colnames <- c("MB01"
                   , "MB06"
                   , "AU06"
                   , "AU06D"
                   , "UA06"
                   , "UA06D"
                   , "TA06"
                   , "TA06D"
                   , "RC06"
                   , "RC06D"
                   , "DHB"
                   , "DHBD"
)
area.colClasses <- c("numeric"
                     , "numeric"
                     , "numeric"
                     , "factor" 
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
)
area.aggregation <- read.csv(
  "data/2006 Census Areas/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = area.colClasses
)
colnames(area.aggregation) <- area.colnames

# meshblocks
meshblocks <- readOGR("data/NZTM/", "MB06_LV2")
# crashes the EC2 free tier instance
meshblocks@data$MB06 <- as.numeric(as.character(meshblocks@data$MB06))
# convert factor to numeric.  Go to character first, otherwise you
# get the factor levels, not the original numeric values.

# join meshblocks and concordance
# interestingly, the concordance has more meshblocks than the shapefile.
length(unique(concordance$MB06))
length(unique(meshblocks@data$MB06))
# never mind.
meshblocks@data <- join(meshblocks@data, concordance, by = "MB06")
meshblocks@data <- join(meshblocks@data, area.aggregation, by = "MB06")

# union polygons by urban.rural
# first, code the classifications A-G and Z
urban.rural <- data.frame(urban.rural = levels(meshblocks@data$urban.rural), code = c("Z", "G", "B", "A", "D", "F", "E", "C"))
meshblocks@data <- join(meshblocks@data, urban.rural, by = "urban.rural")
head(meshblocks@data)
# subset by urban.rural
meshblocksA <- subset(meshblocks, meshblocks@data$code == "A")
meshblocksB <- subset(meshblocks, meshblocks@data$code == "B")
meshblocksC <- subset(meshblocks, meshblocks@data$code == "C")
meshblocksD <- subset(meshblocks, meshblocks@data$code == "D")
meshblocksE <- subset(meshblocks, meshblocks@data$code == "E")
meshblocksF <- subset(meshblocks, meshblocks@data$code == "F")
meshblocksG <- subset(meshblocks, meshblocks@data$code == "G")
meshblocksZ <- subset(meshblocks, meshblocks@data$code == "Z")
# union each one
meshblocksAunion <- unionSpatialPolygons(meshblocksA, meshblocksA@data$code)
meshblocksBunion <- unionSpatialPolygons(meshblocksB, meshblocksB@data$code)
meshblocksCunion <- unionSpatialPolygons(meshblocksC, meshblocksC@data$code)
meshblocksDunion <- unionSpatialPolygons(meshblocksD, meshblocksD@data$code)
meshblocksEunion <- unionSpatialPolygons(meshblocksE, meshblocksE@data$code)
meshblocksFunion <- unionSpatialPolygons(meshblocksF, meshblocksF@data$code)
meshblocksGunion <- unionSpatialPolygons(meshblocksG, meshblocksG@data$code)
meshblocksZunion <- unionSpatialPolygons(meshblocksZ, meshblocksZ@data$code)

# Do
####

ur.legend <- ddply(urban.rural, .(code), function(x) (paste(as.character(x$code), as.character(x$urban.rural))))$V1

# plot A=Urban
plot(districts, col = districts@data$DISTRICT_N, lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "white", add = TRUE)
title(main = "A = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)

# plot AB=Urban
plot(districts, col = districts@data$DISTRICT_N, lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "white", add = TRUE)
title(main = "AB = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)

# plot ABC=Urban
plot(districts, col = districts@data$DISTRICT_N, lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "white", add = TRUE)
title(main = "ABC = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)

# plot ABCD=Urban
plot(districts, col = districts@data$DISTRICT_N, lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksDunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "white", add = TRUE)
title(main = "ABCD = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)

# plot ABCDE=Urban
plot(districts, col = districts@data$DISTRICT_N, lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksDunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksEunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "white", add = TRUE)
title(main = "ABCDE = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)