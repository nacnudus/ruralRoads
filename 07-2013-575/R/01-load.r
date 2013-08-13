# load the crashes
crashes <- loadCrashes("data/BoP-coordinates.csv")

# meshblock ID per crash ID ----------------------------------------------
ID <- over(crashes , meshblocks)
crashMeshblockID <- cbind(crashes@data$id, ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/crashMeshblockID.txt")