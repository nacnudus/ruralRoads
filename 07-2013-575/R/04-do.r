# The hourly profile of urban/rural differs.  Rural crashes peak at 1600 , urban
# at 1700.  Rural have a small peak between 0100 and 0200 whereas Urban crashes
# are low at that time.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_density() + 
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)

# To put that in context, there are more rural crashes than urban.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)

ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge") +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)

# Now in terms of road length.  Far more road is rural
signif(mSummaryBoP[, c("roadLength", "highway")], digits = 2)
signif(prop.table(mSummaryBoP[, c("roadLength", "highway")]) * 100, digits = 2)
signif(prop.table(t(mSummaryBoP[, c("roadLength", "highway")])) * 100, digits = 2)


# Crashes per length of road
mCrash <- melt(crashes[, c("crashID", "urbanRural", "stateHighway", "month"
                           , "year", "hour", "weekday", "severity", "count")]
               , id.vars = c("crashID", "urbanRural", "stateHighway", "month"
                             , "year", "hour", "weekday", "severity", "count"))
crashUrbanRural <- dcast(mCrash, year ~ urbanRural + stateHighway, sum
                         , margins = c("urbanRural", "stateHighway"))
crashUrbanRural

crashUrbanRural$ruralAllByRoad <- 
  crashUrbanRural$`rural_(all)` / (mSummaryBoP["rural", "roadLength"] + 
                                     mSummaryBoP["rural", "highway"] / 1000)
crashUrbanRural$urbanAllByRoad <- 
  crashUrbanRural$`urban_(all)` / (mSummaryBoP["urban", "roadLength"] + 
                                     mSummaryBoP["urban", "highway"] / 1000)

crashUrbanRural$ruralRoadByRoad <- 
  crashUrbanRural$rural_FALSE / (mSummaryBoP["rural", "roadLength"] / 1000)
crashUrbanRural$urbanRoadByRoad <- 
  crashUrbanRural$urban_FALSE / (mSummaryBoP["urban", "roadLength"] / 1000)
crashUrbanRural$ruralHighwayByHighway <- 
  crashUrbanRural$rural_TRUE / (mSummaryBoP["rural", "highway"] / 1000)
crashUrbanRural$urbanHighwayByHighway <- 
  crashUrbanRural$urban_TRUE / (mSummaryBoP["urban", "highway"] / 1000)
crashUrbanRural

# Now in terms of area.  Far more area is rural, too.
mSummaryBoP[, c("urbanRural", "area")]

# Crashes per area
crashUrbanRural$ruralByArea <- 
  (crashUrbanRural$rural_FALSE + crashUrbanRural$rural_TRUE) / 
  (mSummaryBoP["rural", "area"] / 1000)
crashUrbanRural$urbanByArea <- 
  (crashUrbanRural$urban_FALSE + crashUrbanRural$urban_TRUE) / 
  (mSummaryBoP["urban", "area"] / 1000)
crashUrbanRural

mCrashUrbanRural <- melt(crashUrbanRural, id.vars = "year")

# As graphs
# pure crashes
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("rural_(all)", "urban_(all)"), ]
       , aes(year, value
             , group = variable
             , fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")
# crashes by area
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralByArea", "urbanByArea"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")
# crashes by road length
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralRoadByRoad", "urbanRoadByRoad"
                                                         , "ruralHighwayByHighway", "urbanHighwayByHighway"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")
