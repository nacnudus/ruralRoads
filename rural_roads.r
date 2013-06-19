require(rgeos)
require(rgdal)

#############
# Load Data #
#############

concordance <- read.csv(
  file("/home/nacnudus/R/rural_roads/data/concordance-2006.csv")
  , header = TRUE
  )
colnames(concordance) <- c("meshblock", "urban.rural", "main.urban.area")

meshblocks <- readOGR("/home/nacnudus/R/rural_roads/data", "MB06_LV2")
# crashes the EC2 free tier instance