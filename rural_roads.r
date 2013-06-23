require(rgeos)
require(rgdal)
require(plyr)
require(ggplot2)

# Load Data
############

concordance <- read.csv(
  file("/home/nacnudus/R/rural_roads/data/concordance-2006.csv")
  , header = TRUE
  , colClasses = "factor"
  )
colnames(concordance) <- c("id", "urban.rural", "main.urban.area")
# has to be "id" so it can be joined to the polygons.
# trouble is, sometimes has to be factor, sometimes character.  TODO.

# aggregations into larger areas
# prepare column headings
area.columns <- c("MB01"
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
area.aggregation <- read.csv(
  "/home/nacnudus/R/rural_roads/data/2006 Census Areas/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = "factor"
  )
colnames(area.aggregation) <- area.columns
# trouble is, txt file doesn't pad the MB06 field.
area.aggregation$MB06 <- factor(sprintf(as.character(area.aggregation$MB06)
                                        , format = "%7d")
                                )

meshblocks <- readOGR("/home/nacnudus/R/rural_roads/data/NZTM/", "MB06_LV2")
# crashes the EC2 free tier instance

# some meshblocks have several polygons:
table(meshblocks@data$MB06)[table(meshblocks@data$MB06) > 1]
# map one with loads of polygons.
mb3154201 <- meshblocks[meshblocks@data$MB06 == "3154201", ]
p.mb3154201 <- fortify(mb3154201)
ggplot(data=p.mb3154201, aes(long, lat, group = group)) + geom_polygon(colour='black', fill = 'white') + theme_bw()
# see?!

# now try joining onto concordance.
# interestingly, the concordance has more meshblocks than the shapefile.
length(unique(concordance$MB06))
length(unique(meshblocks@data$MB06))
# never mind.
joinblocks <- join(meshblocks@data, concordance)
joinblocks <- join(joinblocks, area.aggregation)
meshblocks@data <- joinblocks
# pick an area
clutha <- meshblocks[meshblocks@data$TA06D == "Clutha District", ]
f.clutha <- fortify(clutha, region = "MB06") # "region" sets the "id"
j.clutha <- join(f.clutha, c.concordance, by = "id")
ggplot(data = j.clutha
       , aes(long, lat, group = id, fill = urban.rural)
       ) + geom_polygon()

# do the lot?
fmb <- ldply(meshblocks@polygons
             , .fun = function(x) (fortify(x, region = "MB06"))
             , .parallel = TRUE
             , .progress = "progress_text"
             )