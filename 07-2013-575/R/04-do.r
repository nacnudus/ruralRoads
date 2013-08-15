# CAS data extracted on 15 August 2013.


# load --------------------------------------------------------------------

# load crashMeshblocks - this will only exist if the relevant code in
# 02-clean.r has been run, but try to avoid that.
crashMeshblocks <- read.table("output/crashMeshblockID.txt"
                              , header = TRUE
                              , quote = "\"")
# same goes for meshblocksBoP, which is just a list of BoP meshblock IDs
meshblocksBoP <- read.table("output/meshblocksBoP.txt"
                              , header = TRUE
                              , quote = "\"") # then carry on cleaning



# clean -------------------------------------------------------------------

# join coordinates to meshblocks to urban/rural to crashes
crashes2 <- join(coordinates@data, crashMeshblocks, type = "inner")
crashes2 <- join(crashes2, meshblockUrban, by = "meshblockID", type = "inner")
crashes2 <- join(crashes2, crashes, type = "inner")

# define urban as A:D
crashes2$urban <- as.character(crashes2$code) <= "C"
crashes2$urban[crashes2$urban == TRUE] <- "urban"
crashes2$urban[crashes2$urban == FALSE] <- "rural"




# analyse -----------------------------------------------------------------

# The hourly profile of urban/rural differs.  Rural crashes peak at 1600 , urban
# at 1700.  Rural have a small peak between 0100 and 0200 whereas Urban crashes
# are low at that time.
ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_density() + 
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)

# To put that in context, there are more rural crashes than urban.
ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)

ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge") +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)

# Now in terms of road length.  Far more road is rural.
roadLength <- dcast(mData[!is.na(mData$value) & mData$variable == "roadLength", ]
                    , variable ~ urban, sum)
roadLength

# Crashes per length of road
mCrash <- melt(crashes2[, c("crashID", "urban", "month", "year", "hour"
                            , "weekday", "severity", "count")]
               , id.vars = c("crashID", "urban", "month", "year", "hour"
                             , "weekday", "severity"))
crashUrbanRural <- dcast(mCrash, year ~ urban, sum)
crashUrbanRural$ruralByRoad <- crashUrbanRural$rural / (roadLength$rural / 1000)
crashUrbanRural$urbanByRoad <- crashUrbanRural$urban / (roadLength$urban / 1000)
crashUrbanRural

# Now in terms of area.  Far more area is rural, too.
area <- dcast(mData[!is.na(mData$value) & mData$variable == "area", ]
                        , variable ~ urban, sum)
area

# Crashes per area
crashUrbanRural$ruralByArea <- crashUrbanRural$rural / (area$rural / 1000)
crashUrbanRural$urbanByArea <- crashUrbanRural$urban / (area$urban / 1000)
crashUrbanRural

# As graphs
# pure crashes
mCrashUrbanRural <- melt(crashUrbanRural, id.vars = "year")
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("rural", "urban"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")
# crashes by area
mCrashUrbanRural <- melt(crashUrbanRural, id.vars = "year")
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralByArea", "urbanByArea"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")
# crashes by road length
mCrashUrbanRural <- melt(crashUrbanRural, id.vars = "year")
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralByRoad", "urbanByRoad"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")


