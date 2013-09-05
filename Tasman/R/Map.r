
# function ----------------------------------------------------------------

source("../R/01-function.r")


# load --------------------------------------------------------------------

load("../output/spatialData.Rdata")
coordinates <- loadCrashes("data/coordinates.csv")


# clean -------------------------------------------------------------------

# subset for Bay of Plenty meshblocks
meshblocksT <- subset(meshblocks, meshblocks@data$policeDistrict == "TASMAN" & 
                          meshblocks@data$urbanRural == "urban")
# shake everything up a bit to prevent any non-noded intersections errors
meshblocksT <- gBuffer(meshblocksT, width=0, byid=TRUE)
# union all polygons in each one to speed up plotting
meshblocksT <- unionSpatialPolygons(meshblocksT, rep(1, length(meshblocksT@polygons)))

# subset for highways
highways <- subset(roads500k, !is.na(roads500k@data$hway_num))

# subset for Bay of Plenty stations
stationsT <- subset(stations, stations@data$DISTRICT_N == "Tasman")

# labels for stations
stationLabels <- as.data.frame(gCentroid(stationsT,byid=TRUE)@coords)
stationLabels$label <- stationsT@data$STATION_NA


# do ----------------------------------------------------------------------

# plot and save
png("plots/Tasman.png", width=420/2, height=594/2, units="mm", res=600) # A4 portrait
plot(stationsT, lwd = 0.4, col = "lightgrey")
plot(coastline, lwd = 0.4, add = TRUE)
plot(meshblocksT, lwd = 0.2, col = "lightblue", add = TRUE)
plot(highways, lwd = 0.4, lty = 2, col = "blue", add = TRUE)
plot(coordinates, col = alpha("red", 0.2), pch = 16, cex = 0.5, add = TRUE)
text(stationLabels$x, stationLabels$y, labels = stationLabels$label, cex = 0.75)
dev.off()