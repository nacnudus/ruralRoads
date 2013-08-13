# code to load crashes from .csv
crashes <- loadCrashes("data/BoP2008-12.csv")

# subset meshblocks by getting the relevant stations and putting
# them over the meshblocks
crashStations <- crashes %over% stations
# returns a data frame, so you have to subset the spatial polygons yourself
crashStations <- subset(stations, stations$STATION_ID %in% unique(crashStations$STATION_ID))
# you can't use %over% when both sides are the same class, so use gIntersection
crashMeshblocks <- crashStations %over% meshblocks
# I don't know why the subset( syntax doesn't work here, so use [
x <- subset(meshblocks, meshblocks@data$MB06 %in% unique(crashMeshblocks))

# subset meshblocks by ruralness and optimise them for plotting.
meshblocksList <- dlply(urban.rural
                        , .(code)
                        , function(x) (subsetMeshblock(as.character(x$code)))
                        , .progress = "text")
# meshblocks is now a list of eight SpatialPolygonsDataFrames, named A to Z e.g.
# meshblocks$D is a subset of all meshblocks in the A to D ruralness categories.

crashes <- dlply(urban.rural
                 , .(code)
                 , function(x) (subsetCrashes(crashes, x$code)))

crashMeshblocks <- gIntersection(crashStations, meshblocks)

plot(meshblocksList$D, col = "grey")
plot(meshblocksList$C, col = "green", add = TRUE)
plot(meshblocksList$B, col = "blue", add = TRUE)
plot(meshblocksList$A, col = "red", add = TRUE)
plot(coastline, add = TRUE)

urbanCrashes <- over(crashes, as(meshblocksList$D,"SpatialPolygons"))
crashes@data$rural <- is.na(urbanCrashes)
qplot(easting, northing, data = as.data.frame(crashes))

# meshblock ID per crash ID ----------------------------------------------
ID <- over(crashes , meshblocks)
crashMeshblockID <- cbind(crashes@data$id, ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/crashMeshblockID.txt")

# road length per meshblock - nice try -----------------------------------
ID <- over(roads500k, meshblocks) # nope, too many gigabytes
# start again by trimming out roads that don't intersect
# using code from this StackOverflow question:
# http://stackoverflow.com/questions/16918767/
roads.sub <- gIntersects(roads500k, meshblocks$A, byid=TRUE) # test for areas that don't intersect
roads.sub2 <- apply(roads.sub, 2, function(x) {sum(x)}) # test across all roads in the SpatialLines whether it intersects or not
roads.sub3 <- roads[roads.sub2 > 0] # keep only the ones that actually intersect
# perform the intersection. This takes a while since it also calculates area and other things, which is why we trimmed out irrelevant areas first
int <- gIntersection(roads.sub3, meshblocks$A, byid=TRUE) # intersect the spatialLines and the meshblocks

# this works fine but takes a few minutes (quite a few)
roadsFeatherston <- gIntersection(roads50k, subset(meshblocks, meshblocks$UA06D == "Featherston"))
# try with a much larger meshblock
system.time(roadsA <- gIntersection(roads50k, meshblocksList$D))
# try with roads50k
roadsA <- gIntersection(roads50k, meshblocksList$A)

# area per meshblock ------------------------------------------------------
Area <- laply(meshblocks@polygons, function(x) (x@area))
meshblockArea <- as.data.frame(cbind(meshblocks@data$MB06, Area))
write.table(meshblockArea
            , row.names = FALSE
            , col.names = c("MB06", "area")
            , file = "output/meshblockArea.txt")