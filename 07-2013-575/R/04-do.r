# CAS data extracted on 15 August 2013.

# load crashMeshblocks - this will only exist if the relevant code in
# 02-clean.r has been run, but try to avoid that.
crashMeshblocks <- read.table("output/crashMeshblockID.txt"
                              , header = TRUE
                              , quote = "\"")
# same goes for meshblocksBoP, which is just a list of BoP meshblock IDs
meshblocksBoP <- read.table("output/meshblocksBoP.txt"
                              , header = TRUE
                              , quote = "\"") # then carry on cleaning

# join coordinates to meshblocks to urban/rural to crashes
crashes2 <- join(coordinates@data, crashMeshblocks, type = "inner")
crashes2 <- join(crashes2, meshblockUrban, by = "meshblockID", type = "inner")
crashes2 <- join(crashes2, crashes, type = "inner")

# define urban as A:D
crashes2$urban <- as.character(crashes2$code) <= "D"
crashes2$urban[crashes2$urban == TRUE] <- "urban"
crashes2$urban[crashes2$urban == FALSE] <- "rural"

# The hourly profile of urban/rural differs.  Rural crashes peak between 1200 
# and 1600, urban at 1700.  Rural have a small peak at 0200 whereas Urban
# crashes are low at that time.
ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_density() + 
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)

# But to put that in context, there are far fewer rural crashes.
ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_density() + 
  aes(y = ..count..) +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)


# Now in terms of road length.  Far more road is rural.
roadLength <- dcast(mData[!is.na(mData$value), ]
                    , variable ~ urban, sum)
roadLength

# Crashes per length of road
mCrash <- melt(crashes2[, c("crashID", "urban", "month", "year", "hour"
                            , "weekday", "severity", "count")]
               , id.vars = c("crashID", "urban", "month", "year", "hour"
                             , "weekday", "severity"))
crashUrbanRural <- dcast(mCrash, year ~ urban, sum)



ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour)) + 
  geom_bar(binwidth = 1, position = "dodge") +
  scale_x_continuous(breaks = seq(0,24,4)) +
  facet_grid(. ~ urban)