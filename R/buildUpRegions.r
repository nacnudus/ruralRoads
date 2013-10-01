# Build up from meshblocks to station, area and district polygons that
# exclude islands.  This is faster than gIntersection on coastpoly.

load("output/spatialData.Rdata")

# Offshore meshblocks can be subsetted by their exclusion from the urban/rural profile.
land <- subset(meshblocks, meshblocks$urbanRuralGrade != "Area outside urban/rural profile")

# Stations first.
# Unique rows of landData for IDs.
landData <- land@data
landData <- as(landData, "data.frame")[!duplicated(landData$policeStation)
                                     , c("policeDistrict", "policeArea", "policeStation", "AU06D", "UA06D")]
rownames(landData) <- landData$policeStation
# gBuffer rebuilds the geometries to be valid.
stationsPoly <- gBuffer(land, width = 0, byid = TRUE, id = seq(1, length(land@polygons)))
# Union by station
stationsPoly <- unionSpatialPolygons(stationsPoly, IDs = stationsPoly$policeStation)
# Reapply the data
stationsPoly <- SpatialPolygonsDataFrame(stationsPoly, landData)

# Repeat for areas
landData <- as(landData, "data.frame")[!duplicated(landData$policeArea)
                                     , c("policeDistrict", "policeArea", "AU06D", "UA06D")]
rownames(landData) <- landData$policeArea
areasPoly <- unionSpatialPolygons(stationsPoly, IDs = stationsPoly$policeArea)
areasPoly <- SpatialPolygonsDataFrame(areasPoly, landData)

# Repeat for districts
landData <- as(landData, "data.frame")[!duplicated(landData$policeDistrict)
                                     , c("policeDistrict", "AU06D", "UA06D")]
rownames(landData) <- landData$policeDistrict
districtsPoly <- unionSpatialPolygons(areasPoly, IDs = areasPoly$policeDistrict)
districtsPoly <- SpatialPolygonsDataFrame(districtsPoly, landData)
