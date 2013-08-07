# code to load crashes from .csv
bop <- read.csv("data/BoPCoordinates.csv", quote = "\"")

# BoP
bop <- bop[, c("CRASH.ID", "EASTING", "NORTHING")]
colnames(bop) <- c("id", "easting", "northing")
bopsp <- SpatialPointsDataFrame(coords = bop[, 2:3], data=bop)
proj4string(bopsp) <- proj4string(meshblocks$A) # same crs as meshblocks

# subset BoP by ruralness
bopA <- bopA <- gIntersection(bopsp, meshblocksAunion)
bopB <- bopB <- gIntersection(bopsp, meshblocksBunion)
bopC <- bopC <- gIntersection(bopsp, meshblocksCunion)
bopD <- bopD <- gIntersection(bopsp, meshblocksDunion)
bopE <- bopE <- gIntersection(bopsp, meshblocksEunion)
bopF <- bopF <- gIntersection(bopsp, meshblocksFunion)
bopG <- bopG <- gIntersection(bopsp, meshblocksGunion)
bopZ <- bopZ <- gIntersection(bopsp, meshblocksZunion)