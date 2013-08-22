# roads -------------------------------------------------------------------

# subset highways
highways500k <- subsetHighways(roads500k)
highways50k <- subsetHighways(roads50k)


# concordance -------------------------------------------------------------

colnames(concordance) <- c("meshblockID"
                           , "urbanRuralGrade"
                           , "mainUrbanArea")
# "meshblockID" is essential for joining to meshblocks@data using the plyr
# join because the joining columns must be named the same.  An alternative
# is `merge` in base R.



# meshblock area ----------------------------------------------------------

colnames(meshblockArea) <- c("meshblockID", "area")


# meshblock road length and highway ---------------------------------------

colnames(meshblockRoadLength) <- c("meshblockID", "roadLength")
colnames(meshblockHighway) <- c("meshblockID", "highway")


# census areas ------------------------------------------------------------

colnames(censusAreas) <- c("MB01" # not needed---the 2001 meshblock ID
                           , "meshblockID"
                           , "AU06" # ordinary columns are numeric codes
                           , "AU06D" # 'D' columns are the human-readable version
                           , "UA06"
                           , "UA06D"
                           , "TA06"
                           , "TA06D"
                           , "RC06"
                           , "RC06D"
                           , "DHB"
                           , "DHBD")
# meshblockID should be character for consistency with other meshblockID fields
censusAreas$meshblockID <- as.character(censusAreas$meshblockID)


# census demographics -----------------------------------------------------

colnames(censusData)[1:2] <- c("meshblockID", "population")
# all figures relate to the normally-resident population

# police 123-person stations ----------------------------------------------

colnames(x123) <- c("STATION_NA", "AREA_NAME", "DISTRICT_N")
# "STATION_NA" is essential for joining to meshblocks@data using the plyr
# join because the joining columns must be named the same.  An alternative
# would be `merge` in base R.

# x123 lacks a field to say "rural" because they all are rural, but one is
# useful after joining to the stations polygons so that you can tell which
# stations aren't in the x123 list of rural stations.
x123$rural <- TRUE # after the join, stations@data$rural will be TRUE or NA


# stations ----------------------------------------------------------------

# TODO: function to join crashes and stations

# join stations and 123-person-station concordance
stations@data <- join(stations@data
                      , x123[, c("STATION_NA", "rural")]
                      , by = "STATION_NA")
# urban stations have NA in $rural after the join because this column comes
# from the x123 side of the join and there was obviously no match for 
# urban stations in x123.
stations@data[is.na(stations@data$rural), "rural"] <- FALSE

# assign colour for plotting
stations@data$colour[stations@data$rural == TRUE] <- "grey"
stations@data$colour[stations@data$rural == FALSE] <- "white"

# create labels for plotting
# use the centre of each polygon to position the label
stationLabels <- as.data.frame(gCentroid(stations,byid=TRUE)@coords)
stationLabels$label <- stations@data$STATION_NA
stationLabels$district <- stations@data$DISTRICT_N


# meshblocks --------------------------------------------------------------

colnames(meshblocks@data)[1] <- "meshblockID"

# "meshblockID" is the unique ID so should be character, not a factor or
# numeric.
meshblocks@data$meshblockID <- as.character(meshblocks@data$meshblockID)


# join meshblocksBoP to other datasets -----------------------------------
# urban/rural, area, road length, census areas and censusData demographics

# note: fewer meshblocks in the shapefile than the concordance because the
# concordance includes offshore islands---see README.md

# urban/rural concordance
meshblocks@data <- join(meshblocks@data, concordance, by = "meshblockID")

# urbanRural classification
meshblocks@data <- join(meshblocks@data, urbanRural)
meshblocks@data$code <- as.character(meshblocks@data$code) # for subsetting
                                                           # by ruralness
meshblocks@data <- join(meshblocks@data, meshblockArea)
meshblocks@data <- join(meshblocks@data, meshblockRoadLength)
meshblocks@data <- join(meshblocks@data, meshblockHighway)
meshblocks@data <- join(meshblocks@data, censusAreas, by = "meshblockID")
meshblocks@data <- join(meshblocks@data, censusData)


# write meshblocks@data to file -------------------------------------------

# particularly useful for loading onto less-powerful EC2 instances, which
# aren't able to get this far from shapefiles

# the unique is just to make sure, but it should be unique anyway.
write.table(unique(meshblocks@data[, c("meshblockID"
                                       , "urbanRuralGrade"
                                       , "code"
                                       , "urbanRural"
                                       , "area"
                                       , "roadLength"
                                       , "highway"
                                       , "population"
                                       , "Male"
                                       , "Female"
                                       , "X0.4.Years"
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
                                       , "X65.Years.and.Over"
                                       , "Asian.Ethnic.Groups"
                                       , "European.Ethnic.Groups"
                                       , "Maori.Ethnic.Group"
                                       , "Pacific.Peoples..Ethnic.Groups"
                                       , "MELAA.Ethnic.Groups"
                                       , "Other.Ethnic.Groups"
                                       , "AU06D"
                                       , "UA06D"
                                       , "TA06D"
                                       , "RC06D"
                                       , "DHBD")])
            , row.names = FALSE
            , file = "output/meshblockData.txt")


# subset meshblocks by ruralness and optimise -----------------------------

# this is temperamental---if it doesn't work the first time, try again.

meshblocksList <- dlply(urbanRural
                        , .(code)
                        , function(x) (
                          subsetMeshblock(as.character(x$code)))
                        , .progress = "text")
# meshblocks is now a list of eight SpatialPolygonsDataFrames,
# named A to Z e.g. meshblocks$D is a subset of all meshblocks 
# in the D ruralness category.


# spatialData file --------------------------------------------------------

# for quickly loading into a new EC2 instance without having to compute it
# from scratch

save(meshblocks, meshblocksList, stations, stationLabels, districts, areas
     , stations, coastline, coastpoly, roads500k, roads50k
     , file = "output/spatialData.Rdata")
