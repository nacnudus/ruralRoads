# meshblockData -----------------------------------------------------------

# convert meshblockID from numeric to character, which means the colClass
# function will report it to melt as an id variable.
meshblockData$meshblockID <- as.character(meshblockData$meshblockID)


# T meshblocks ----------------------------------------------------------

meshblockDataT <- meshblockData[meshblockData$policeDistrict == "TASMAN", ]

# nicer ethnic groups for joining to drivers/victims
colnames(meshblockDataT)[25:30] <- c("Asian", "European", "NZ Maori"
                                       , "Pacific Islander"
                                       , "MELAA.Ethnic.Groups", "Other")
meshblockDataT$Other2 <- rowSums(meshblockDataT[, c("MELAA.Ethnic.Groups"
                                                        , "Other")]
                                   , na.rm = TRUE)
meshblockDataT <- meshblockDataT[, !(names(meshblockDataT) %in% c("MELAA.Ethnic.Groups", "Other"))]
names(meshblockDataT)[names(meshblockDataT) == "Other2"] <- "Other"

# create a nice summary
mDataT <- melt(meshblockDataT, id.vars <- which(!colClass(meshblockDataT)))

SummaryT <- dcast(mDataT, urbanRural ~ variable, sum, na.rm = TRUE
                    , margins = "grand_column")
rownames(SummaryT) <- c("rural", "urban", "other") # for easy subsetting

# summarize ageGroup population
ageGroupPopulation <- dcast(mDataT[grep("[0-9]+[.]Years"
                                          , mDataT$variable), ]
                            , variable ~ .
                            , sum
                            , na.rm = TRUE)
colnames(ageGroupPopulation) <- c("ageGroup", "population")


# classify crashes by meshblock  ------------------------------------------

# for getting the urban/rural classification

# 02-load.r should have attempted to load crashMeshblocks from file, but if
# it has failed then it has to be computed from scratch.  Note that this
# requires spatial data to be in memory.  You can get this with
# load(../output/spatialData.Rdata) or you can run the code in ../R to
# compute that afresh too.

if (!exists("crashMeshblocks")) {
  if (!exists("meshblocks")) {
    load("../output/spatialData.Rdata")
  }
  Coordinates <- loadCrashes("data/coordinates.csv")
  crashMeshblocks <- joinCrashesMeshblocks(Coordinates
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
colnames(drivers) <- c("count", "crashID", "sex", "age", "injury", "role"
                       , "driverAtFault", "licence", "overseas", "ethnicity")
colnames(victims) <- c("count", "crashID", "driverPassengerOther", "sex", "age"
                       , "injury", "role", "driverAtFault", "ethnicity")
colnames(driversCauses) <- c("count", "crashID", "role", "driverCause"
                             , "driverCauseCategory")


# crashes -----------------------------------------------------------------

# filter out the rubbish
crashes <- crashes[!is.na(crashes$year), ]
crashes <- crashes[as.character(crashes$severity) %in% c("Fatal", "Serious"), ]
crashes$year <- as.factor(crashes$year)

# crashes$hour is bizarre.  Hour 25 is CAS's version of an NA.  Hour 1 is
# between midnight and 0100 hours.
crashes$hour <- as.numeric(crashes$hour)
crashes$hour[crashes$hour == 25] <- NA
crashes$hour <- crashes$hour - 1

# get weekdays by name
crashes$weekday <- wday(ymd(paste(crashes$year, crashes$month, crashes$day)))
crashes$weekday <- factor(crashes$weekday)
# name them
levels(crashes$weekday) <-  c("Monday", "Tuesday", "Wednesday", "Thursday"
                              , "Friday", "Saturday", "Sunday")

# get urban/rural
crashes <- join(crashes, crashMeshblocks)
crashes <- crashes[!is.na(crashes$urbanRural), ]
crashes$urbanRuralHighway <- crashes$urbanRural

# tidy up stateHighway
levels(crashes$stateHighway) <- c("road", "highway")

# new urban/rural/stateHighway column
crashes$urbanRuralHighway <- crashes$urbanRural
# expand the factor levels first
levels(crashes$urbanRuralHighway) <- c(levels(crashes$urbanRuralHighway)
                                       , "highway")
# then change some to the new level ("State Highway")
crashes$urbanRuralHighway[crashes$stateHighway == "highway"] <- "highway"

# make new urban/rural/road/highway column good for plotting
crashes$urbanRuralRoadHighway <- factor(paste(crashes$urbanRural, crashes$stateHighway))
crashes$urbanRuralRoadHighway <- factor(crashes$urbanRuralRoadHighway
                                         , levels = c("rural road"
                                                      , "urban road"
                                                      , "rural highway"
                                                      , "urban highway"))


# drivers -----------------------------------------------------------------

# get urbanRural and stateHighway from the crashes
drivers <- join(drivers, crashes[, c("crashID", "urbanRural", "stateHighway")])

# aggregate ethnicities into groups
ethnicGroup <- read.csv(header = TRUE, 
                        stringsAsFactors = TRUE, 
                        text="ethnicity,ethnicGroup
Asian,Other
Cook Islander,Pacific Islander
European,European
Fijian,Pacific Islander
NZ Maori,NZ Maori
Other,Other
Other Pacific Islander,Pacific Islander
Samoan,Pacific Islander
Tongan,Pacific Islander
Unknown,Pacific Islander
Pacific Islander,Pacific Islander")
drivers$ethnicity <- factor(join(data.frame(ethnicity = drivers$ethnicity)
                                 , ethnicGroup
                                 , by = "ethnicity")$ethnicGroup)
rm(ethnicGroup)

# aggregate ages into groups
drivers$ageGroup <- cut(drivers$age, breaks=c(seq(0, 69, 5), 100)
                  , right = FALSE
                  , labels=c("X0.4.Years"
                             , "X5.9.Years"
                             , "X10.14.Years"
                             , "X15.19.Years"
                             , "X20.24.Years"
                             , "X25.29.Years"
                             , "X30.34.Years"
                             , "X35.39.Years"
                             , "X40.44.Years"
                             , "X45.49.Years"
                             , "X50.54.Years"
                             , "X55.59.Years"
                             , "X60.64.Years"
                             , "X65.Years.and.Over"))


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


# normalize by population etc. --------------------------------------------

# population
crashes$countPopulation <- crashes$count / (SummaryT[crashes$urbanRural, "population"] / 1000)
drivers$countAgeGroupPopulation <- drivers$count / (join(drivers, ageGroupPopulation)$population / 1000)
drivers <- join(drivers, ddply(drivers
                               , .(crashID, role)
                               , function(x) (data.frame(countUrbanEthnicity = x$count
                                                         / (SummaryT[as.character(x$urbanRural)
                                                                       , as.character(x$ethnicity)]
                                                            / 1000)))), by = c("crashID", "role"))

# road
crashes <- join(crashes, ddply(crashes
                               , .(crashID)
                               , function(x) (data.frame(countRoad = x$count 
                                                         / (SummaryT[as.character(x$urbanRural)
                                                                       , as.character(x$stateHighway)] 
                                                            / 1000)))), by = "crashID")

# crashes/urbanRural/hour
y <- crashes[!is.na(crashes$hour), ]
crashes <- join(y
  , ddply(y
          , .(crashID)
          , function(x) (
            data.frame(countCrashUrbanHour = x$count / 
                         sum(y[crashes$urbanRural == x$urbanRural 
                               & crashes$hour == x$hour
                               , "count"] / 100 # percentage of all crashes
                             , na.rm = TRUE)))), by = "crashID")
rm(y)

# crashes/urbanRural/weekday/hour
# copy the crashes, filter for ones with hours, weight, then join back on
y <- crashes[!is.na(crashes$hour), ]
crashes <- join(y
                , ddply(y
                  , .(crashID)
                  , function(x) (
                    data.frame(countCrashUrbanWeekdayHour = x$count / 
                                 sum(y[y$urbanRural == x$urbanRural 
                                       & y$hour == x$hour
                                       & y$weekday == x$weekday
                                       , "count"] / 100 # percentage of all crashes
                                     , na.rm = TRUE))))[, c("crashID", "countCrashUrbanWeekdayHour")], by = "crashID")
rm(y)

# crashes/urbanRural/weekday/hour but hours grouped into threes for histogramming
crashes$hour3 <- findInterval(crashes$hour, vec = seq(0, 21, 3)) * 3 - 3
y <- crashes[!is.na(crashes$hour3), ]
crashes <- join(y
                , ddply(y
                        , .(crashID)
                        , function(x) (
                          data.frame(countCrashUrbanWeekdayHour3 = sum(x$count) / 
                                       sum(y[y$urbanRural == x$urbanRural 
                                             & y$hour3 == x$hour3
                                             & y$weekday == x$weekday
                                             , "count"] / 100 # percentage of all crashes
                                           , na.rm = TRUE))))[, c("crashID", "countCrashUrbanWeekdayHour3")])