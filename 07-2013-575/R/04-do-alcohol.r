# like 04-do.r but looking at alcohol crashes.

# The hourly profile of urban/rural differs.  Rural crashes peak at 1600 , urban
# at 1700.  Rural have a small peak between 0100 and 0200 whereas Urban crashes
# are low at that time.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour, group = alcohol, fill = alcohol, alpha = 0.2)) + 
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)

# To put that in context, there are more rural crashes than urban.
ggplot(crashes[!is.na(crashes$hour), ]
       , aes(hour, group = alcohol, colour = alcohol, alpha = 0.2)) + 
  geom_bar(aes(fill = alcohol), binwidth = 1, position = "stack") +
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(urbanRural ~ stateHighway)


# tables  -----------------------------------------------------------------

# In terms of road length.  Far more road is rural
signif(SummaryBoP[, c("roadLength", "highway")], digits = 2)
signif(prop.table(SummaryBoP[, c("roadLength", "highway")]) * 100, digits = 2)
signif(prop.table(t(SummaryBoP[, c("roadLength", "highway")])) * 100, digits = 2)

# Crashes per length of road
mCrash <- melt(crashes[, c("crashID", "urbanRural", "stateHighway", "month"
                           , "year", "hour", "weekday", "severity", "alcohol", "count")]
               , id.vars = c("crashID", "urbanRural", "stateHighway", "month"
                             , "year", "hour", "weekday", "severity", "alcohol", "count"))
crashUrbanRural <- dcast(mCrash, year ~ urbanRural + stateHighway, sum
                         , margins = c("urbanRural", "stateHighway"))
crashUrbanRural

crashUrbanRural$ruralAllByRoad <- 
  crashUrbanRural$`rural_(all)` / (SummaryBoP["rural", "roadLength"] + 
                                     SummaryBoP["rural", "highway"] / 1000)
crashUrbanRural$urbanAllByRoad <- 
  crashUrbanRural$`urban_(all)` / (SummaryBoP["urban", "roadLength"] + 
                                     SummaryBoP["urban", "highway"] / 1000)

crashUrbanRural$ruralRoadByRoad <- 
  crashUrbanRural$rural_road / (SummaryBoP["rural", "roadLength"] / 1000)
crashUrbanRural$urbanRoadByRoad <- 
  crashUrbanRural$urban_road / (SummaryBoP["urban", "roadLength"] / 1000)
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

