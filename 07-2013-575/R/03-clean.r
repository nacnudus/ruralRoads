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
colnames(drivers) <- c("count", "crashID", "sex", "age", "injury"
                       , "role", "driverAtFault", "licence", "ethnicity", "overseas")
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
crashes <- crashes[!is.na(crashes$urbanRural), ]
crashes$urbanRuralHighway <- crashes$urbanRural
crashes$year <- as.factor(crashes$year)

# make stateHighway logical
levels(crashes$stateHighway) <- c("road", "highway")

# new urban/rural/stateHighway column
crashes$urbanRuralHighway <- crashes$urbanRural
# expand the factor levels first
levels(crashes$urbanRuralHighway) <- c(levels(crashes$urbanRuralHighway)
                                       , "highway")
# then change some to the new level ("State Highway")
crashes$urbanRuralHighway[crashes$stateHighway == "highway"] <- "highway"


# meshblockData -----------------------------------------------------------

# convert meshblockID from numeric to character, which means the colClass
# function will report it to melt as an id variable.
meshblockData$meshblockID <- as.character(meshblockData$meshblockID)


# BoP meshblocks ----------------------------------------------------------

meshblockDataBoP <- meshblockData[meshblockData$policeDistrict == "BAY OF PLENTY", ]

# create a nice summary
mDataBoP <- melt(meshblockDataBoP, id.vars <- which(!colClass(meshblockDataBoP)))
SummaryBoP <- dcast(mDataBoP, urbanRural ~ variable, sum, na.rm = TRUE
                  , margins = "grand_column")
rownames(SummaryBoP) <- c("rural", "urban", "other") # for easy subsetting


# apply crash lookup tables -----------------------------------------------

# replace driverCauseCategory column with one that distinguishes between
# alcohol, no alcohol, and drugs.
driversCauses$driverCauseCategory <- NULL
driversCauses <- join(driversCauses, causeCategories)

# driver faults
drivers <- join(drivers, faultCategories)


# mix 'n' match crashes, causes, victims, etc. ------------------------------

# alcohol
drivers$alcohol <- !is.na(join(drivers, driversCauses[driversCauses$driverCauseCategory == "Alcohol", ], match = "first")[, "driverCauseCategory"])
# reverse TRUE/FALSE factor level to put TRUE on the bottom of stacked graphs.
drivers$alcohol <- as.factor(drivers$alcohol)
drivers$alcohol <- factor(drivers$alcohol, levels = c(TRUE, FALSE))

crashes$alcohol <- crashes$crashID %in% drivers[drivers$fault == TRUE & drivers$alcohol == TRUE, "crashID", ]
# reverse TRUE/FALSE factor level to put TRUE on the bottom of stacked graphs.
crashes$alcohol <- as.factor(crashes$alcohol)
crashes$alcohol <- factor(crashes$alcohol, levels = c(TRUE, FALSE))

victims$alcohol  <- (victims$crashID %in% crashes[crashes$alcohol == TRUE, "crashID"])
# reverse TRUE/FALSE factor level to put TRUE on the bottom of stacked graphs.
drivers$alcohol <- as.factor(drivers$alcohol)
drivers$alcohol <- factor(drivers$alcohol, levels = c(TRUE, FALSE))

# ethnicity



# normalize crashes by population/road ------------------------------------

crashes$countPopulation <- crashes$count / (SummaryBoP[crashes$urbanRural, "population"] / 1000)
crashes$countRoad <- ddply(crashes, .(crashID), function(x) (SummaryBoP[as.character(x$urbanRural), as.character(x$stateHighway)] /1000))$V1
