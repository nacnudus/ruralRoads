# code to load crashes from .csv
crashes <- loadCrashes("data/BoP2008-12.csv")

# subset meshblocks by getting the relevant stations and putting
# them over the meshblocks
crashStations <- crashes %over% stations # returns a data frame, so you have to
# subset the spatial polygons yourself
crashStations <- subset(stations, stations$STATION_ID %in% unique(crashStations$STATION_ID))
crashMeshblocks <- crashStations %over% meshblocks
crashMeshblocks <- subset(meshblocks, meshblocks$STATION_ID %in% unique(crashStations$STATION_ID))

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
crashMeshblockID <- cbind(crashes@data$id ,ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/crashMeshblockID.txt")
