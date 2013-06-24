require(rgeos)
require(rgdal)
require(plyr)
require(ggplot2)

# Load Data
############

# urban/rural concordance
concordance <- read.csv(
  file("/home/nacnudus/R/rural_roads/data/concordance-2006.csv")
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
  "/home/nacnudus/R/rural_roads/data/2006 Census Areas/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = area.colClasses
  )
colnames(area.aggregation) <- area.colnames

# meshblocks
meshblocks <- readOGR("/home/nacnudus/R/rural_roads/data/NZTM/", "MB06_LV2")
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

# pick an area to plot
wellington <- meshblocks[meshblocks@data$TA06D == "Wellington City", ]
f.wellington <- fortify(wellington, region = "MB06") # "region" sets the "id"
colnames(f.wellington)[7] <- "MB06"
j.wellington <- join(f.wellington, concordance, by = "MB06")
p.wellington  <- ggplot(data = j.wellington
       , aes(long, lat, group = MB06, fill = urban.rural)
       ) + geom_polygon() + coord_fixed()

# save plot
# svg (vector format)
ggsave("wellington.svg"
       , p.wellington
)
# png (raster format A4 landscape)
ggsave("wellington.png"
       , p.wellington
       , width = 297
       , height = 210
       , units = "mm"
       , dpi = 600
       )

# try adding roads
roads <- readOGR("/home/nacnudus/R/rural_roads/data/LINZ_Roads", "nz-mainland-road-centreli")
roads@data$id <- c(1:nrow(roads@data))
wellington.roads <- wellington %over% roads
roads.poly <- roads[na.omit(wellington.roads$id), ] # don't know why it gives NAs
f.roads.poly <- fortify(roads.poly) # can't use region here: auto-numbered.
j.roads.poly <- join(f.roads.poly, wellington.roads, by = "id")
p.roads  <- ggplot(data = j.roads.poly
                        , aes(long, lat, group = id, colour = surface)
) + geom_line() + coord_fixed()