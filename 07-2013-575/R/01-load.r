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