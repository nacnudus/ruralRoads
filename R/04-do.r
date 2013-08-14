# load crashes from .csv -------------------------------------------------

crashes <- loadCrashes("data/BoP2008-12.csv")


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


# subset meshblocks by ruralness and optimise -----------------------------

meshblocksList <- dlply(urban.rural
                        , .(code)
                        , function(x) (subsetMeshblock(as.character(x$code)))
                        , .progress = "text")
# meshblocks is now a list of eight SpatialPolygonsDataFrames,
# named A to Z e.g. meshblocks$D is a subset of all meshblocks 
# in the D ruralness category.