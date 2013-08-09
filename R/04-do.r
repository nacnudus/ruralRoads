# code to load crashes from .csv
crashes <- loadCrashes("data/BoP 2008-12.csv")

# subset meshblocks by getting the relevant stations and putting
# them over the meshblocks
crashStations <- crashes %over% stations # returns a data frame, so you have to
# subset the spatial polygons yourself
crashStations <- subset(stations, stations$STATION_ID %in% unique(crashStations$STATION_ID))
crashMeshblocks <- crashStations %over% meshblocks
crashMeshblocks <- subset(meshblocks, meshblocks$STATION_ID %in% unique(crashStations$STATION_ID))

# subset meshblocks by ruralness and optimise them for plotting.
meshblocks <- dlply(urban.rural, .(code), function(x) (subsetMeshblock(x$code)), .progress = "text")
# meshblocks is now a list of eight SpatialPolygonsDataFrames, named A to Z e.g.
# meshblocks$D is a subset of all meshblocks in the A to D ruralness categories.

crashes <- dlply(urban.rural
                 , .(code)
                 , function(x) (subsetCrashes(crashes, x$code)))

crashMeshblocks <- gIntersection(crashStations, meshblocks)