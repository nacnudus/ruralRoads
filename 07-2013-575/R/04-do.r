# The hourly profile of urban/rural differs.  Rural crashes peak at 1600 , urban
# at 1700.  Rural have a small peak between 0100 and 0200 whereas Urban crashes
# are low at that time.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_density() + 
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urbanRuralHighway)

# To put that in context, there are more rural crashes than urban.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urbanRuralHighway)

ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge") +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urbanRuralHighway)

# Now in terms of road length.  Far more road is rural.
mSummaryBoP[, c("urbanRural", "roadLength")]

# Crashes per length of road
mCrash <- melt(crashes[, c("crashID", "urbanRural", "month", "year", "hour"
                            , "weekday", "severity", "count")]
               , id.vars = c("crashID", "urbanRural", "month", "year", "hour"
                             , "weekday", "severity"))
crashUrbanRural <- dcast(mCrash, year ~ urbanRural, sum)
crashUrbanRural$ruralByRoad <- 
  crashUrbanRural$rural / (mSummaryBoP["rural", "roadLength"] / 1000)
crashUrbanRural$urbanByRoad <- 
  crashUrbanRural$urban / (mSummaryBoP["urban", "roadLength"] / 1000)
crashUrbanRural

# Now in terms of area.  Far more area is rural, too.
mSummaryBoP[, c("urbanRural", "area")]

# Crashes per area
crashUrbanRural$ruralByArea <- 
  crashUrbanRural$rural / (mSummaryBoP["rural", "area"] / 1000)
crashUrbanRural$urbanByArea <- 
  crashUrbanRural$urban / (mSummaryBoP["urban", "area"] / 1000)
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


