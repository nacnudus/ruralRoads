# Investigates the CAS data quality, e.g. how many crashes have coordinates?

# Note that only unique crashIDs are counted.  For example, the code
# dataQuality(driversCauses.) takes unique crashIDs from the Coordinates
# table, and sees how many unique matching crashIDs there are in the crashes
# table. You could say, for all those crashes that have at least one
# driver cause, so many don't even have an entry in the Coordinates table.

# It is also mysterious that there are no crashes in the crashes table prior
# to 2010

source("R/01-function.r")
source("R/02-load.r")
source("R/03-clean.r")

require(reshape2)


# dataQuality function ---------------------------------------------------

# returns a table of missing values and their proportion to the whole,
# having joined all other tables to a given table, x.

dataQuality <- function(x) {
  # fails if there is no missing data - but that's a good thing, right?
  z <- melt(x[, 2:5], measure.vars = 1:4)
  z <- dcast(z, variable ~ value, length)
  z <- cbind(z
             , sum = rowSums(z[, -1])
             , z[, -1] / rowSums(z[, -1]))
  return(z)
}


# coordinates. -----------------------------------------------------------

Coordinates <- loadCrashes("data/coordinates.csv")

# left join all the other tables onto Coordinates to see how many matches there
# are.

coordinates. <- data.frame(crashID = unique(Coordinates@data[, "crashID"]))
coordinates. <- join(coordinates.
                     , data.frame(crashID = crashes$crashID
                                  , crashes = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = drivers$crashID
                                  , drivers = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = victims$crashID
                                  , victims = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = driversCauses$crashID
                                  , driversCauses = 1)
                     , match = "first")


# crashes. ---------------------------------------------------------------

# left join all the other tables onto crashes to see how many matches there are

crashes. <- data.frame(crashID = unique(crashes[, "crashID"]))
crashes. <- join(crashes.
                     , data.frame(crashID = Coordinates@data$crashID
                                  , coordinates = 1)
                     , match = "first")
crashes. <- join(crashes.
                     , data.frame(crashID = drivers$crashID
                                  , drivers = 1)
                     , match = "first")
crashes. <- join(crashes.
                     , data.frame(crashID = victims$crashID
                                  , victims = 1)
                     , match = "first")
crashes. <- join(crashes.
                     , data.frame(crashID = driversCauses$crashID
                                  , driversCauses = 1)
                     , match = "first")


# drivers. ---------------------------------------------------------------

# left join all the other tables onto drivers to see how many matches there are

drivers. <- data.frame(crashID = unique(drivers[, "crashID"]))
drivers. <- join(drivers.
                 , data.frame(crashID = Coordinates@data$crashID
                              , coordinates = 1)
                 , match = "first")
drivers. <- join(drivers.
                 , data.frame(crashID = crashes$crashID
                              , crashes = 1)
                 , match = "first")
drivers. <- join(drivers.
                 , data.frame(crashID = victims$crashID
                              , victims = 1)
                 , match = "first")
drivers. <- join(drivers.
                 , data.frame(crashID = driversCauses$crashID
                              , driversCauses = 1)
                 , match = "first")


# victims. ---------------------------------------------------------------

# left join all the other tables onto victims to see how many matches there are

victims. <- data.frame(crashID = unique(victims[, "crashID"]))
victims. <- join(victims.
                 , data.frame(crashID = Coordinates@data$crashID
                              , coordinates = 1)
                 , match = "first")
victims. <- join(victims.
                 , data.frame(crashID = crashes$crashID
                              , crashes = 1)
                 , match = "first")
victims. <- join(victims.
                 , data.frame(crashID = drivers$crashID
                              , drivers = 1)
                 , match = "first")
victims. <- join(victims.
                 , data.frame(crashID = driversCauses$crashID
                              , driversCauses = 1)
                 , match = "first")


# driversCauses. ---------------------------------------------------------------

# left join all the other tables onto driversCauses to see how many matches there
# are

driversCauses. <- data.frame(crashID = unique(driversCauses[, "crashID"]))
driversCauses. <- join(driversCauses.
                 , data.frame(crashID = Coordinates@data$crashID
                              , coordinates = 1)
                 , match = "first")
driversCauses. <- join(driversCauses.
                 , data.frame(crashID = crashes$crashID
                              , crashes = 1)
                 , match = "first")
driversCauses. <- join(driversCauses.
                 , data.frame(crashID = drivers$crashID
                              , drivers = 1)
                 , match = "first")
driversCauses. <- join(driversCauses.
                 , data.frame(crashID = victims$crashID
                              , victims = 1)
                 , match = "first")

dataQuality(coordinates.)
dataQuality(crashes.)
dataQuality(drivers.)
dataQuality(victims.)
dataQuality(driversCauses.)


# are any Area Units a mixture of urban/rural? ----------------------------

# it makes integration with NZ.Stat census data possible.

x <- unique(meshblockDataBoP[, c("AU06D", "urbanRural")])
nrow(x)
length(unique(x$AU06D)) # maybe, but
y <- dcast(x[!is.na(x$urbanRural), ], AU06D ~ urbanRural, length
           , margins = "grand_row")
y[y$`(all)` > 1, ] # they were only mixtures of urban/rural and NA

# same goes for the national picture
x <- unique(meshblockData[, c("AU06D", "urbanRural")])
nrow(x)
length(unique(x$AU06D))
y <- dcast(x[!is.na(x$urbanRural), ], AU06D ~ urbanRural, length
           , margins = "grand_row")
y[y$`(all)` > 1, ]