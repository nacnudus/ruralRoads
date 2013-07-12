require(rgeos)
require(rgdal)
require(maptools)
require(mapproj)
require(plyr)
require(ggplot2)

# Load Data
############

# urban/rural concordance
concordance <- read.csv(
  file("./data/concordance-2006.csv")
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
  "./data/2006 Census Areas/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = area.colClasses
  )
colnames(area.aggregation) <- area.colnames

# meshblocks
meshblocks <- readOGR("./data/NZTM/", "MB06_LV2")
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
# wellington
wellington <- meshblocks[meshblocks@data$TA06D == "Wellington City", ]
f.wellington <- fortify(wellington, region = "MB06") # "region" sets the "id"
colnames(f.wellington)[7] <- "MB06"
j.wellington <- join(f.wellington, concordance, by = "MB06")
p.wellington  <- ggplot(data = j.wellington
                        , aes(long, lat, group = MB06, fill = urban.rural)
) + 
  geom_polygon() + 
  coord_fixed()  + 
  scale_fill_brewer(palette="Dark2")

# bay of plenty & waikato
bop <- meshblocks[meshblocks@data$RC06D == "Bay of Plenty Region" | meshblocks@data$RC06D == "Waikato Region", ]
f.bop <- fortify(bop, region = "MB06") # "region" sets the "id"
colnames(f.bop)[7] <- "MB06"
j.bop <- join(f.bop, concordance, by = "MB06")
p.bop  <- ggplot(data = j.bop
                 , aes(long, lat, group = MB06, fill = urban.rural)
) + 
  geom_polygon() + 
  coord_fixed() + 
  scale_fill_brewer(palette="Dark2")

# load roads
roads <- readOGR("./data/LINZ_Roads", "nz-mainland-road-centreli")
roads@data$id <- c(1:nrow(roads@data))

# prepare roads
bop.roads <- bop %over% roads
roads.poly <- roads[omit.na(bop.roads$id), ] # don't know why it gives NAs
f.roads.poly <- fortify(roads.poly) # can't use region here: auto-numbered.
f.roads.poly$id <- as.numeric(f.roads.poly$id)
j.roads.poly <- join(f.roads.poly, bop.roads, by = "id")
# order it, otherwise geom_path appears to close loops
j.roads.poly <- j.roads.poly[order(j.roads.poly$id, j.roads.poly$order), ]

# overlay roads
p.bop  <- ggplot(data = j.bop
                 , aes(long, lat)
) + geom_polygon(aes(long, lat, group = MB06, fill = urban.rural)
                 , data = j.bop) + 
  coord_fixed() + 
  scale_fill_brewer(palette="Dark2") + 
  geom_path(aes(long, lat, group = id, colour = surface)
            , data = j.roads.poly) +
  geom_point(aes(easting, northing), data = crashes)

# save plot
# png (raster format A4 landscape)
ggsave("bop.png"
       , p.bop
       , width = 297
       , height = 210
       , units = "mm"
       , dpi = 600
)

# try adding crashes
crashes <- read.csv("./data/BoPCoordinates.csv", quote = "\"")
crashes <- crashes[, c("CRASH.ID", "EASTING", "NORTHING")]
colnames(crashes) <- c("id", "easting", "northing")

# I'll assume for the time being that the projections are equivalent
ggplot(crashes, aes(easting, northing, colour = )) + geom_point()
# okay, overlay main plot
ggplot(data = j.bop
       , aes(long, lat)
) + geom_polygon(aes(long, lat, group = MB06, fill = urban.rural)
                 , data = j.bop) + 
  coord_fixed() + 
  scale_fill_brewer(palette="Dark2") + 
  geom_path(aes(long, lat, group = id, colour = surface)
            , data = j.roads.poly) +
  geom_point(aes(easting, northing), data = crashes)
# it works!

# join crashes to urbanity
urbanity <- read.csv("./data/Urbanity.csv")
crashes <- join(crashes, urbanity)
# add to main plot, shape crashes by urbanity (can't colour as against
# ggplot2 philosophy)
ggplot(data = j.bop
       , aes(long, lat)
) + geom_polygon(aes(long, lat, group = MB06, fill = urban.rural)
                 , data = j.bop) + 
  coord_fixed() + 
  scale_fill_brewer(palette="Dark2") + 
  geom_path(aes(long, lat, group = id, colour = surface)
            , data = j.roads.poly) +
  geom_point(aes(easting, northing, shape = urbanity), data = crashes) + 
  scale_shape(solid = FALSE) + 
  scale_x_continuous(limits=c(1820000, 2020000)) + 
  scale_y_continuous(limits=c(5650000, 5850000))

# attempt colours by removing roads
p.bop <- ggplot(data = j.bop
       , aes(long, lat)
) + geom_polygon(aes(long, lat, group = MB06, fill = urban.rural)
                 , data = j.bop) + 
  coord_fixed() + 
  scale_fill_brewer(palette="Dark2") + 
  geom_point(aes(easting, northing, colour = urbanity, alpha = 0.01), data = crashes) +
  scale_x_continuous(limits=c(1820000, 2020000)) + 
  scale_y_continuous(limits=c(5650000, 5850000)) + 
  scale_colour_manual(values = c("black", "white"))

# save A3 landscape
ggsave("bop.png"
       , p.bop
       , width = 297 * 2
       , height = 210 * 2
       , units = "mm"
       , dpi = 600
)