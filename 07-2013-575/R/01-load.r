coordinates <- loadCrashes("data/BoP-coordinates.csv")
crashes <- read.csv("data/BoP-crashes.txt", header = FALSE)
drivers <- read.csv("data/BoP-drivers.txt", header = FALSE)
driversCauses <- read.csv("data/BoP-drivers-causes.txt", header = FALSE)
victims <- read.csv("data/BoP-victims.txt", header = FALSE)

meshblockUrban <- read.table("../output/meshblockUrbanRural.txt"
                             , header = TRUE
                             , quote = "\"")
meshblockRoadLength <- read.csv("../output/roadLengthByMeshblock.csv"
                                , header = FALSE)
meshblockArea <- read.csv("../output/areaByMeshblock.csv"
                          , header = FALSE)

censusData <- read.table("../data/censusData.txt", header = TRUE, sep = "\t")
# If this doesn't work, open the file in notepad, check there aren't any macrons
# or other characters not in UTF-8, then save in the UTF-8 text encoding and
# try again.