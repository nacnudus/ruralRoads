# classify crashes by meshblock  ------------------------------------------

# for getting the urban/rural classification

# 02-load.r should have attempted to load crashMeshblocks from file, but if
# it has failed then it has to be computed from scratch.  Note that this
# requires spatial data to be in memory.  You can get this with
# load(../output/spatialData.Rdata) or you can run the code in ../R to
# compute that afresh too.

if (!exists("crashMeshblocks")) {
  crashMeshblocks <- joinCrashesMeshblocks(coordinates
                                           , "output/crashMeshblocks.txt")
}

# join to meshblockData for urban/rural
crashMeshblocks <- join(crashMeshblocks
                        , meshblockData[, c("meshblockID"
                                            , "urbanRuralGrade"
                                            , "code"
                                            , "urbanRural")])


# column headings of datasets ---------------------------------------------

colnames(crashes) <- c("count", "crashID", "day", "month"
                       , "year", "hour", "severity", "stateHighway")
colnames(drivers) <- c("count", "crashID", "role", "injury", "driverAtFault"
                       , "sex", "age", "ethnicity", "licence", "overseas")
colnames(victims) <- c("count", "crashID", "driverPassengerOther", "sex", "age"
                       , "injury", "role", "driverAtFault", "ethnicity")
colnames(driversCauses) <- c("count", "crashID", "role", "driverCause"
                             , "driverCauseCategory")


# crashes -----------------------------------------------------------------

crashes <- crashes[!is.na(crashes$year), ]
crashes$hour <- as.numeric(crashes$hour)
crashes[crashes$hour == 24, "hour"] <- 0
crashes[!(crashes$hour <= 23), "hour"] <- NA
crashes <- crashes[as.character(crashes$severity) %in% c("Fatal", "Serious"), ]
crashes$weekday <- wday(ymd(paste(crashes$year, crashes$month, crashes$day)))
crashes <- join(crashes, crashMeshblocks)

# meshblockData -----------------------------------------------------------

# convert meshblockID from numeric to character, which means the colClass
# function will report it to melt as an id variable.
meshblockData$meshblockID <- as.character(meshblockData$meshblockID)


# BoP meshblocks ----------------------------------------------------------

# 02-load.r should have attempted to load meshblockDataBoP from file, but if
# it has failed then it has to be computed from scratch.  Note that this
# requires spatial data to be in memory.  You can get this with
# load(../output/spatialData.Rdata) or you can run the code in ../R to
# compute that afresh too.

if (!exists("meshblockDataBoP")) {
  districtsBoP <- subset(districts, districts$DISTRICT_N == "BAY OF PLENTY")
  meshblocksBoPID <- over(meshblocks, districtsBoP)
  meshblocksBoP <- subset(meshblocks, !is.na(meshblocksBoPID))
  save(meshblocksBoP, file = "output/meshblocksBoP.Rdata")
  
  meshblockDataBoP <- meshblocksBoP@data
  write.table(meshblockBoP@data
              , row.names = FALSE
              , file = "output/meshblockDataBoP.txt")
}

mData <- melt(meshblockData, id.vars <- which(!colClass(meshblockData)))
mSummary <- dcast(mData[is.numeric(mData$value), ], urbanRural ~ variable, sum, na.rm = TRUE, margins = "grand_column")