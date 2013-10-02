crashes <- read.csv("data/crashes.csv", header = TRUE)
drivers <- read.csv("data/drivers.csv", header = TRUE)
driversCauses <- read.csv("data/drivers-causes.csv", header = TRUE)
victims <- read.csv("data/victims.csv", header = TRUE)

# lookup tables
causeCategories <- read.csv("data/causeCategories.csv")
faultCategories <- read.csv("data/faultCategories.csv", sep = "|")

# Note: no attempt is made to load meshblockBoP.Rdata.  This is because it is
# only ever needed for plotting, and tends to crash small Amazon EC2 instances.

# Read meshblockData from the main output directory.  This gives you area, road
# length, urban/rural, census areas and census demographics.
meshblockData <- read.table("../output/meshblockData.txt", header = TRUE)

# Attempt to read crashMeshblocks from the local output directory.  This gives 
# the meshblockID of every crash in coordinates, as long as it has already been
# computed once (by 03-clean.r).
if (file.exists("output/crashMeshblocks.txt")) {
  crashMeshblocks <- read.table("output/crashMeshblocks.txt"
                                 , header = TRUE
                                 , quote = "\"")
}
