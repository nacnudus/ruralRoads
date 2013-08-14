# roads -------------------------------------------------------------------

# subset highways
highways500k <- subsetHighways(roads500k)
highways50k <- subsetHighways(roads50k)


# concordance -------------------------------------------------------------

colnames(concordance) <- c("MB06", "urban.rural", "main.urban.area")
# "MB06" is essential for joining to meshblocks@data using the plyr join
# because the joining columns must be named the same.  An alternative would
# be `merge` in base R.


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

# Most of these operations crash the EC2 free tier instance.

# MB06 is the unique ID so should be numeric, not a factor.
# Go to character first, otherwise you get the factor levels, not the 
# original numeric values.
meshblocks@data$MB06 <- as.numeric(as.character(meshblocks@data$MB06))
# This and later operations crash the EC2 free tier instance.

# join meshblocks and concordance
# interestingly, the concordance has more meshblocks than the shapefile.
length(unique(concordance$MB06))
length(unique(meshblocks@data$MB06))
# never mind.  Perhaps they are offshore islands.
meshblocks@data <- join(meshblocks@data, concordance, by = "MB06")
meshblocks@data <- join(meshblocks@data, censusAreas, by = "MB06")

# code the classifications A-G and Z via a lookup table.  You can rely on them
# being ordered alphabetically in the factor.
urban.rural <- data.frame(urban.rural = levels(meshblocks@data$urban.rural)
                          , code = c("Z", "G", "B", "A", "D", "F", "E", "C"))
urban.rural <- urban.rural[order(urban.rural$code), ] # reorder
meshblocks@data <- join(meshblocks@data, urban.rural, by = "urban.rural")
meshblocks@data$code <- as.character(meshblocks@data$code) # for subsetting by
                                                           # ruralness
