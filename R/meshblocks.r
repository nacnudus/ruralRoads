require(rgeos)
require(rgdal)
require(maptools)
require(mapproj)
require(plyr)
require(RColorBrewer)

# Global
setwd("/home/nacnudus/R/ruralRoads")

# Load
######

# meshblocks
meshblocks <- readOGR("data/NZTM/", "MB06_LV2")

# Coastline for context and because police boundaries exceed it
coast <- readOGR("data/coastlineLine/", "nz-mainland-coastlines-to")

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

# roads
roads <- readOGR("data/LINZ_roads/", "nz-road-centrelines-topo-")

# Clean
#######

# # simplify the coast polygons
# coast2 <- gSimplify(coast, 0.4, topologyPreserve = TRUE)
# areas <- lapply(coast2@polygons, function(x) sapply(x@Polygons, function(y) y@area))
# bigpolys <- lapply(areas, function(x) which(x > 0.1))
# for(i in 1:length(bigpolys)){
#   if(length(bigpolys[[i]]) >= 1 && bigpolys[[i]][1] >= 1){
#     coast2@polygons[[i]]@Polygons <- coast2@polygons[[i]]@Polygons[bigpolys[[i]]]
#     coast2@polygons[[i]]@plotOrder <- 1:length(coast2@polygons[[i]]@Polygons)
#   }
# }

# # convert coast from spatialLines to spatialPolygons
# coastPolySet <- SpatialLines2PolySet(coast)
# coastPolygons <- PolySet2SpatialPolygons(coastPolySet)
# proj4string(coastPolygons) <- CRS(proj4string(coast))
# # not pretty and won't work.

# subset roads
highways <- subset(roads, !is.na(roads@data$hway_num))

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

# subset by urban.rural (gBuffer prevents non-noded intersections error)
meshblocksA <- gBuffer(subset(meshblocks, meshblocks@data$code == "A"), width=0, byid=TRUE)
meshblocksB <- gBuffer(subset(meshblocks, meshblocks@data$code == "B"), width=0, byid=TRUE)
meshblocksC <- gBuffer(subset(meshblocks, meshblocks@data$code == "C"), width=0, byid=TRUE)
meshblocksD <- gBuffer(subset(meshblocks, meshblocks@data$code == "D"), width=0, byid=TRUE)
meshblocksE <- gBuffer(subset(meshblocks, meshblocks@data$code == "E"), width=0, byid=TRUE)
meshblocksF <- gBuffer(subset(meshblocks, meshblocks@data$code == "F"), width=0, byid=TRUE)
meshblocksG <- gBuffer(subset(meshblocks, meshblocks@data$code == "G"), width=0, byid=TRUE)
meshblocksZ <- gBuffer(subset(meshblocks, meshblocks@data$code == "Z"), width=0, byid=TRUE)
# union all polygons in each one to speed up plotting
meshblocksAunion <- unionSpatialPolygons(meshblocksA, rep(1, length(meshblocksA@polygons)))
meshblocksBunion <- unionSpatialPolygons(meshblocksB, rep(1, length(meshblocksB@polygons)))
meshblocksCunion <- unionSpatialPolygons(meshblocksC, rep(1, length(meshblocksC@polygons)))
meshblocksDunion <- unionSpatialPolygons(meshblocksD, rep(1, length(meshblocksD@polygons)))
meshblocksEunion <- unionSpatialPolygons(meshblocksE, rep(1, length(meshblocksE@polygons)))
meshblocksFunion <- unionSpatialPolygons(meshblocksF, rep(1, length(meshblocksF@polygons)))
meshblocksGunion <- unionSpatialPolygons(meshblocksG, rep(1, length(meshblocksG@polygons))) # still some
  # error but doesn't matter because is never plotted (most rural - plot by elimination)
meshblocksZunion <- unionSpatialPolygons(meshblocksZ, rep(1, length(meshblocksZ@polygons)))

# Do
####


# Plotting

ur.legend <- ddply(urban.rural, .(code), function(x) (paste(as.character(x$code), as.character(x$urban.rural))))$V1
fillcolours <- brewer.pal(12, "Set3")

# plot A=Urban
png("plots/A.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "A = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# plot AB=Urban
png("plots/AB.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "AB = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# plot ABC=Urban
png("plots/ABC.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "ABC = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# plot ABCD=Urban
png("plots/ABCD.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksDunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "ABCD = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# plot ABCDE=Urban
png("plots/ABCDE.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksDunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksEunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "ABCDE = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# plot ABCDEF=Urban
png("plots/ABCDEF.png", width=420, height=594, units="mm", res=600) # A3 portrait
plot(districts, col = fillcolours[districts@data$DISTRICT_N], lwd = 0.2)
plot(meshblocksAunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksBunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksCunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksDunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksEunion, col = "white", lwd = 0.2, add = TRUE)
plot(meshblocksFunion, col = "white", lwd = 0.2, add = TRUE)
plot(coast, lwd = 0.2, col = "black", add = TRUE)
plot(highways, lwd = 0.4, col = "red", add = TRUE)
title(main = "ABCDEF = Urban")
legend("bottomright", legend = ur.legend, cex = 0.75)
dev.off()

# Tagging

# Load BoP
bop <- read.csv("data/BoPCoordinates.csv", quote = "\"")
bop <- bop[, c("CRASH.ID", "EASTING", "NORTHING")]
colnames(bop) <- c("id", "easting", "northing")
bopsp <- SpatialPointsDataFrame(coords = bop[, 2:3], data=bop)
proj4string(bopsp) <- proj4string(meshblocks) # same crs as meshblocks

# subset by ruralness
bopA <- bopA <- gIntersection(bopsp, meshblocksAunion)
bopB <- bopB <- gIntersection(bopsp, meshblocksBunion)
bopC <- bopC <- gIntersection(bopsp, meshblocksCunion)
bopD <- bopD <- gIntersection(bopsp, meshblocksDunion)
bopE <- bopE <- gIntersection(bopsp, meshblocksEunion)
bopF <- bopF <- gIntersection(bopsp, meshblocksFunion)
bopG <- bopG <- gIntersection(bopsp, meshblocksGunion)
bopZ <- bopZ <- gIntersection(bopsp, meshblocksZunion)