# Investigates the CAS data quality, e.g. how many crashes have coordinates?

require(reshape2)


# dataQuality function ----------------------------------------------------

# returns a table of missing values and their proportion to the whole,
# having joined all other tables to a given table, x.

dataQuality <- function(x) {
  z <- melt(x[, 4:7], measure.vars = 1:4)
  z <- dcast(z, variable ~ value)
  z <- cbind(z
             , sum = sum(z[, -1])
             , z[, -1] / rowSums(z[, -1]))
  return(z)
}


# coordinates. -----------------------------------------------------

# left join all the other tables onto coordinates to see how many matches there
# are.

coordinates. <- coordinates@data
coordinates. <- join(coordinates.
                     , data.frame(crashID = crashes$crashID, crashes = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = crashes$crashID, drivers = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = victims$crashID, victims = 1)
                     , match = "first")
coordinates. <- join(coordinates.
                     , data.frame(crashID = driversCauses$crashID
                                  , driversCauses = 1)
                     , match = "first")


