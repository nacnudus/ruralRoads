# Investigates the CAS data quality, e.g. how many crashes have coordinates?

source("R/01-load.r")
source("R/02-clean.r")

require(reshape2)


# dataQuality function ----------------------------------------------------

# returns a table of missing values and their proportion to the whole,
# having joined all other tables to a given table, x.

dataQuality <- function(x) {
  z <- melt(x[, 2:5], measure.vars = 1:4)
  z <- dcast(z, variable ~ value)
  z <- cbind(z
             , sum = sum(z[, -1])
             , z[, -1] / rowSums(z[, -1]))
  return(z)
}


# coordinates. -----------------------------------------------------

# left join all the other tables onto coordinates to see how many matches there
# are.

coordinates. <- data.frame(crashID = coordinates@data[, "crashID"])
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

crashes. <- data.frame(crashID = crashes[, "crashID"])
crashes. <- join(crashes.
                     , data.frame(crashID = coordinates@data$crashID
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

drivers. <- data.frame(crashID = drivers[, "crashID"])
drivers. <- join(drivers.
                 , data.frame(crashID = coordinates@data$crashID
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

victims. <- data.frame(crashID = victims[, "crashID"])
victims. <- join(victims.
                 , data.frame(crashID = coordinates@data$crashID
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

driversCauses. <- data.frame(crashID = driversCauses[, "crashID"])
driversCauses. <- join(driversCauses.
                 , data.frame(crashID = coordinates@data$crashID
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