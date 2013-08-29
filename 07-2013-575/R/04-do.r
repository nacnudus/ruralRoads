# The hourly profile of urban/rural differs.  Rural crashes peak at 1600 , urban
# at 1700.  Rural have a small peak between 0100 and 0200 whereas Urban crashes
# are low at that time.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour)) + 
  geom_density() + 
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)

# To put that in context, there are more rural crashes than urban.
ggplot(crashes[!is.na(crashes$hour), ], aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge", fill = "grey") +
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)


# tables  -----------------------------------------------------------------

# In terms of road length.  Far more road is rural
signif(SummaryBoP[, c("road", "highway")], digits = 2)
signif(prop.table(SummaryBoP[, c("road", "highway")]) * 100, digits = 2)
signif(prop.table(t(SummaryBoP[, c("road", "highway")])) * 100, digits = 2)

# Crashes per length of road
mCrash <- melt(crashes[, c("crashID", "urbanRural", "stateHighway", "month"
                           , "year", "hour", "weekday", "severity", "count")]
               , id.vars = c("crashID", "urbanRural", "stateHighway", "month"
                             , "year", "hour", "weekday", "severity", "count"))
crashUrbanRural <- dcast(mCrash, year ~ urbanRural + stateHighway, sum
                         , margins = c("urbanRural", "stateHighway"))
crashUrbanRural

crashUrbanRural$ruralAllByRoad <- 
  crashUrbanRural$`rural_(all)` / (SummaryBoP["rural", "road"] + 
                                     SummaryBoP["rural", "highway"] / 1000)
crashUrbanRural$urbanAllByRoad <- 
  crashUrbanRural$`urban_(all)` / (SummaryBoP["urban", "road"] + 
                                     SummaryBoP["urban", "highway"] / 1000)

crashUrbanRural$ruralRoadByRoad <- 
  crashUrbanRural$rural_road / (SummaryBoP["rural", "road"] / 1000)
crashUrbanRural$urbanRoadByRoad <- 
  crashUrbanRural$urban_road / (SummaryBoP["urban", "road"] / 1000)
crashUrbanRural$ruralHighwayByHighway <- 
  crashUrbanRural$rural_highway / (SummaryBoP["rural", "highway"] / 1000)
crashUrbanRural$urbanHighwayByHighway <- 
  crashUrbanRural$urban_highway / (SummaryBoP["urban", "highway"] / 1000)
crashUrbanRural

# In terms of area.  Far more area is rural, too.
SummaryBoP[, c("urbanRural", "area")]

# Crashes per area
crashUrbanRural$ruralByArea <- 
  crashUrbanRural$`rural_(all)` / (SummaryBoP["rural", "area"] / 1000)
crashUrbanRural$urbanByArea <- 
  crashUrbanRural$`urban_(all)` / (SummaryBoP["urban", "area"] / 1000)
crashUrbanRural

# In terms of population.  Far more people are urban.
crashUrbanRural$ruralByPopulation <- crashUrbanRural$`rural_(all)` / (SummaryBoP["rural", "population"] / 1000)
crashUrbanRural$urbanByPopulation <- crashUrbanRural$`urban_(all)` / (SummaryBoP["urban", "population"] / 1000)


# graphs ------------------------------------------------------------------

mCrashUrbanRural <- melt(crashUrbanRural, id.vars = "year")

# pure crashes
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("rural_(all)", "urban_(all)"), ]
       , aes(year, value
             , group = variable
             , fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")

# crashes by population
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralByPopulation", "urbanByPopulation"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")

# crashes by road length
ggplot(mCrashUrbanRural[mCrashUrbanRural$variable %in% c("ruralRoadByRoad", "urbanRoadByRoad"
                                                         , "ruralHighwayByHighway", "urbanHighwayByHighway"), ]
       , aes(year, value, group = variable, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge")







ggplot(crashes, aes(hour, countPopulation, group = alcohol)) + geom_bar(stat = "identity") + facet_grid(urbanRural ~ stateHighway)
ggplot(crashes, aes(hour, group = alcohol)) + geom_bar(binwidth = 1) + facet_grid(urbanRural ~ stateHighway)

# pure crashes
# Rural tends to have slightly more crashes than urban, both alcohol-related and
# otherwise, # although urban-non-alcohol crashes increased in 2011&2012 to meet
# rural. Alcohol crashes are declining in both urban&rural.
ggplot(crashes, aes(year, group = urbanRural, fill = urbanRural)) + 
  geom_bar(binwidth = 1, position = "dodge") + facet_wrap(.(alcohol))
ggplot(crashes, aes(alcohol, group = urbanRural, fill = urbanRural)) + 
  geom_bar(binwidth = 1, position = "dodge")

# crashes by road
# Per 1000 km of road, urban highways have by far the worst fatal/serious crash
# rate.
ggplot(crashes, aes(year, weight = countRoad, group = urbanRuralRoadHighway, fill = urbanRuralRoadHighway)) + 
  geom_bar(position = "dodge")
# This probably reflects the amount of traffic at peak times, given the hourly
# profile.
ggplot(crashes[!is.na(crashes$hour & crashes$urbanRuralRoadHighway == "urban highway"), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge", fill = "grey") +
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4))
# However, that cannot be the whole story, or the crash rate on rural highways
# would be lower, because traffic volumes are lower.
ggplot(crashes[!is.na(crashes$hour && crashes$stateHighway == "highway"), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge", fill = "grey") +
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_wrap(.(urbanRural))

# crashes by population
ggplot(crashes, aes(year, weight = countPopulation, group = urbanRural, fill = urbanRural)) + 
  geom_bar(position = "dodge") + facet_wrap(.(alcohol))