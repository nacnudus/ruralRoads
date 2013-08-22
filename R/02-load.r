# meshblocks --------------------------------------------------------------

meshblocks <- readOGR("data/meshblocks/", "MB06_LV2")


# urban/rural concordance to meshblocks -----------------------------------

concordance <- read.csv(
  file("data/concordance-2006.csv")
  , header = TRUE
  , colClasses = c("numeric", "factor", "factor"))


# census areas ------------------------------------------------------------

censusAreas <- read.csv("data/2006 Census Areas.txt", header = FALSE)


# census demographics -----------------------------------------------------

# All figures relate to the normally-resident population.

# If this doesn't work, open the file in notepad, check there aren't any macrons
# or other characters not in UTF-8, then save in the UTF-8 text encoding and
# try again.

censusData <- read.csv("data/censusData.txt")


# meshblock area ----------------------------------------------------------

# refer to README.md for how to make this file from scratch with PostGIS
meshblockArea <- read.csv("output/areaByMeshblock.csv"
                          , header = FALSE)

# meshblock road length ---------------------------------------------------

# refer to README.md for how to make these files from scratch with PostGIS
meshblockRoadLength <- read.csv("output/roadLengthByMeshblock.csv"
                                , header = FALSE)
meshblockHighway <- read.csv("output/highwayByMeshblock.csv"
                                , header = FALSE)

# police districts/areas/stations polygons --------------------------------

districts <- readOGR("data/police_boundaries/nz-police-district-bounda/"
                     , "nz-police-district-bounda")
areas <- readOGR("data/police_boundaries/nz-police-area-boundaries/"
                 , "nz-police-area-boundaries")
stations <- readOGR("data/police_boundaries/nz-police-station-boundar/"
                    , "nz-police-station-boundar")


# police 123-person stations ----------------------------------------------

x123 <- read.table(
  file("data/123.txt")
  , header = FALSE
  , sep = "\t")


# coast line and polygon --------------------------------------------------

coastline <- readOGR("data/coast/nz-mainland-coastlines-to/"
                     , "nz-mainland-coastlines-to")
coastpoly <- readOGR("data/coast/nz-coastlines-and-islands/"
                     , "nz-coastlines-and-islands")


# roads from LINZ 50k 500k ------------------------------------------------

roads500k <- readOGR("data/roads/nz-road-centrelines-topo-/"
                     , "nz-road-centrelines-topo-")
roads50k <- readOGR("data/roads/nz-mainland-road-centreli/"
                    , "nz-mainland-road-centreli")