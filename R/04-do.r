# Define urban.rural vector ----------------------------------------------

# This is done already in R/03-clean.r, so best to use that code as it may
# be more up-to-date).
urban.rural <- data.frame(urban.rural = levels(meshblocks@data$urban.rural)
                          , code = c("Z", "G", "B", "A", "D", "F", "E", "C"))
urban.rural <- urban.rural[order(urban.rural$code), ] # reorder


# load crashes from .csv -------------------------------------------------

crashes <- loadCrashes("data/BoP2008-12.csv")


# subset meshblocks by ruralness and optimise them for plotting ----------

meshblocksList <- dlply(urban.rural
                        , .(code)
                        , function(x) (subsetMeshblock(as.character(x$code)))
                        , .progress = "text")
# meshblocks is now a list of eight SpatialPolygonsDataFrames,
# named A to Z e.g. meshblocks$D is a subset of all meshblocks 
# in the A to D ruralness categories.


# subset crashes by ruralness via meshblocks ------------------------------

crashes <- dlply(urban.rural
                 , .(code)
                 , function(x) (subsetCrashes(crashes, x$code)))


# visualize urban/rural meshblocks ----------------------------------------

plot(meshblocksList$D, col = "grey")
plot(meshblocksList$C, col = "green", add = TRUE)
plot(meshblocksList$B, col = "blue", add = TRUE)
plot(meshblocksList$A, col = "red", add = TRUE)
plot(coastline, add = TRUE)


# visualize urban/rural crashes -------------------------------------------

urbanCrashes <- over(crashes, as(meshblocksList$D, "SpatialPolygons"))
crashes@data$rural <- is.na(urbanCrashes)
qplot(easting, northing, data = as.data.frame(crashes))


# meshblock ID per crash ID ----------------------------------------------
ID <- over(crashes , meshblocks)
crashMeshblockID <- cbind(crashes@data$id, ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/crashMeshblockID.txt")


# area per meshblock ------------------------------------------------------
Area <- laply(meshblocks@polygons, function(x) (x@area))
meshblockArea <- as.data.frame(cbind(meshblocks@data$MB06, Area))
write.table(meshblockArea
            , row.names = FALSE
            , col.names = c("MB06", "area")
            , file = "output/meshblockArea.txt")


# road length per meshblock -----------------------------------------------

# refer to ruralRoads/README.md for how to do this with PostGIS, or just
# use ruralRoads/output/roadPerMeshblock.txt