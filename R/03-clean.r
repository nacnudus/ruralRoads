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


# meshblock road length ---------------------------------------------------

colnames(meshblockRoadLength) <- c("meshblockID", "roadLength")


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

# "meshblockID" is the unique ID so should be numeric, not a factor.
# Go to character first, otherwise you get the factor levels, not the 
# original numeric values.
meshblocks@data$meshblockID <- 
  as.numeric(as.character(meshblocks@data$meshblockID))


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
meshblocks@data <- join(meshblocks@data, censusAreas, by = "meshblockID")
meshblocks@data <- join(meshblocks@data, censusData)


# write meshblocks@data to file -------------------------------------------

# particularly useful for loading onto less-powerful EC2 instances, which
# aren't able to get this far from shapefiles

write.table(unique(meshblocks@data[, c("meshblockID", "urbanRuralGrade"
                                       , "code", "urbanRural")])
            , row.names = FALSE
            , col.names = c("meshblockID", "urbanRuralGrade"
                            , "code", "urbanRural")
            , file = "output/meshblockData.txt")


# subset meshblocks by ruralness and optimise -----------------------------

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