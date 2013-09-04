load("../output/spatialData.Rdata")
source("../R/01-function.r")

coordinates <- loadCrashes("data/BoP-coordinates.csv")

# subset for Bay of Plenty meshblocks
meshblocksBoP <- subset(meshblocks, meshblocks@data$policeDistrict == "BAY OF PLENTY" & 
                          meshblocks@data$urbanRural == "urban")
# shake everything up a bit to prevent any non-noded intersections errors
meshblocksBoP <- gBuffer(meshblocksBoP, width=0, byid=TRUE)
# union all polygons in each one to speed up plotting
meshblocksBoP <- unionSpatialPolygons(meshblocksBoP, rep(1, length(meshblocksBoP@polygons)))

# subset for highways
highways <- subset(roads500k, !is.na(roads500k@data$hway_num))

# subset for Bay of Plenty stations
stationsBoP <- subset(stations, stations@data$DISTRICT_N == "Bay of Plenty")

# labels for stations
stationLabels <- as.data.frame(gCentroid(stationsBoP,byid=TRUE)@coords)
stationLabels$label <- stationsBoP@data$STATION_NA

# plot and save
png("plots/BayOfPlenty.png", width=10, height=10, units="in", res=600)
plot(stationsBoP, lwd = 0.2, col = "lightgrey")
plot(coastline, lwd = 0.2, add = TRUE)
plot(meshblocksBoP, lwd = 0.2, col = "lightblue", add = TRUE)
plot(highways, lwd = 0.2, col = "red", add = TRUE)
plot(coordinates, col = alpha("darkgreen", 0.2), pch = 16, cex = 0.5, add = TRUE)
text(stationLabels$x, stationLabels$y, labels = stationLabels$label, cex = 0.2)
dev.off()