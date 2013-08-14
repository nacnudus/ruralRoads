# classify crashes by meshblock  ------------------------------------------
ID <- over(coordinates , meshblocks)
crashMeshblocks <- cbind(coordinates@data$id, ID[, "MB06"])
colnames(crashMeshblocks) <- c("crashID", "meshblockID")
write.table(crashMeshblocks
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID")
            , file = "output/urbanRural.txt")

# column headings of the other crash datasets ----------------------------
colnames(crashes) <- c("count", "crashID", "severity", "day", "month"
                       , "year", "hour", "stateHighway")
colnames(drivers) <- c("count", "crashID", "role", "injury", "driverAtFault"
                       , "sex", "age", "ethnicity", "licence", "overseas")
colnames(victims) <- c("count", "crashID", "driverPassengerOther", "sex", "age"
                       , "injury", "role", "driverAtFault", "ethnicity")
colnames(driversCauses) <- c("count", "crashID", "role", "driverCause"
                             , "driverCauseCategory")


# remove crashes with year = NA (there was one once) ---------------------
crashes <- crashes[!is.na(crashes$year), ]
crashes$hour <- as.numeric(crashes$hour)
crashes[crashes$hour == 24, "hour"] <- 0
crashes[!(crashes$hour <= 23), "hour"] <- NA
