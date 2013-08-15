# classify crashes by meshblock  ------------------------------------------
ID <- over(coordinates , meshblocks)
crashMeshblocks <- data.frame(cbind(coordinates@data$crashID, ID[, "MB06"]))
colnames(crashMeshblocks) <- c("crashID", "meshblockID")
write.table(crashMeshblocks
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID")
            , file = "output/crashMeshblockID.txt")

# column headings of the other crash datasets ----------------------------
colnames(crashes) <- c("count", "crashID", "day", "month"
                       , "year", "hour", "severity", "stateHighway")
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
crashes <- crashes[as.character(crashes$severity) %in% c("Fatal", "Serious"), ]
crashes$weekday <- wday(ymd(paste(crashes$year, crashes$month, crashes$day)))


# BoP meshblocks ----------------------------------------------------------

districtBoP <- subset(districts, districts$DISTRICT_N == "BAY OF PLENTY")
meshblocksBoPID <- over(meshblocks, districtBoP)
meshblocksBoP <- subset(meshblocks, !is.na(meshblocksBoPID))
colnames(meshblocksBoP@data)[1] <- "meshblockID"
write.table(unique(meshblocksBoP@data[, c("meshblockID")])
            , row.names = FALSE
            , file = "output/meshblocksBoP.txt")

colnames(meshblockRoadLength) <- c("meshblockID", "roadLength")

meshblocksData <- meshblocksBoP@data[, c("meshblockID", "code")]
# code urban as ABC, rural DEFGZ
meshblocksData$urban <- as.character(meshblocksData$code) <= "C"
meshblocksData$urban[meshblocksData$urban == TRUE] <- "urban"
meshblocksData$urban[meshblocksData$urban == FALSE] <- "rural"

meshblocksData <- join(meshblocksData, meshblockRoadLength)
meshblocksData <- join(meshblocksData, meshblockArea)
mData <- melt(meshblocksData, id.vars <- c("meshblockID", "code", "urban"))
