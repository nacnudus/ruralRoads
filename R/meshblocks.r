require(rgeos)
require(rgdal)
require(maptools)
require(mapproj)
require(plyr)
require(ggplot2)

# Global
setwd("/home/nacnudus/R/ruralRoads")

# Load Data
############

# urban/rural concordance
concordance <- read.csv(
  file("data/concordance-2006.csv")
  , header = TRUE
  , colClasses = c("numeric", "factor", "factor")
)
colnames(concordance) <- c("MB06", "urban.rural", "main.urban.area")
# later, "MB06" has to be "id" so it can be joined to the polygons.
# trouble is, sometimes has to be factor, sometimes character.  TODO.

# aggregations into larger areas
# prepare column headings and classes
area.colnames <- c("MB01"
                   , "MB06"
                   , "AU06"
                   , "AU06D"
                   , "UA06"
                   , "UA06D"
                   , "TA06"
                   , "TA06D"
                   , "RC06"
                   , "RC06D"
                   , "DHB"
                   , "DHBD"
)
area.colClasses <- c("numeric"
                     , "numeric"
                     , "numeric"
                     , "factor" 
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
                     , "numeric"
                     , "factor"
)
area.aggregation <- read.csv(
  "data/2006 Census Areas/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = area.colClasses
)
colnames(area.aggregation) <- area.colnames

# meshblocks
meshblocks <- readOGR("data/NZTM/", "MB06_LV2")
# crashes the EC2 free tier instance
meshblocks@data$MB06 <- as.numeric(as.character(meshblocks@data$MB06))
# convert factor to numeric.  Go to character first, otherwise you
# get the factor levels, not the original numeric values.

# join meshblocks and concordance
# interestingly, the concordance has more meshblocks than the shapefile.
length(unique(concordance$MB06))
length(unique(meshblocks@data$MB06))
# never mind.
meshblocks@data <- join(meshblocks@data, concordance, by = "MB06")
meshblocks@data <- join(meshblocks@data, area.aggregation, by = "MB06")