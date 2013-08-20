# meshblocks --------------------------------------------------------------

meshblocks <- readOGR("data/meshblocks/", "MB06_LV2")


# urban/rural concordance to meshblocks -----------------------------------

concordance <- read.csv(
  file("data/concordance-2006.csv")
  , header = TRUE
  , colClasses = c("numeric", "factor", "factor"))


# census areas ------------------------------------------------------------

# prepare column headings and classes
censusAreas.colnames <- c("MB01"
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
                          , "DHBD")
censusAreas.colClasses <- c("numeric"
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
                            , "factor")
# load
censusAreas <- read.csv(
  "data/2006 Census Areas.txt"
  , header = FALSE
  , colClasses = censusAreas.colClasses)

# rename columns (really a clean operation by since the preparation
# was done here...)
colnames(censusAreas) <- censusAreas.colnames


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