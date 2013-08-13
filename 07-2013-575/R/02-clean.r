# classify crashes by urban/rural ----------------------------------------
ID <- over(coordinates , meshblocks)
urbanRural <- cbind(coordinates@data$id, ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/urbanRural.txt")
