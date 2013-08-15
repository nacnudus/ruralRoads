# Map various regions to decide whether D is urban/rural.
# Ensure there's a "plot" directory before printing to file.

# function ----------------------------------------------------------------

subsetMeshblock <- function(x, y) {
  # "mrs" stands for "meshblocks rural subset"
  mrs <- subset(y, y@data$grade == x)
  # shake everything up a bit to prevent any non-noded intersections errors
  mrs <- gBuffer(mrs, width=0, byid=TRUE)
  # union all polygons in each one to speed up plotting
  mrs <- unionSpatialPolygons(mrs, rep(1, length(mrs@polygons)))
  return(mrs)
}


# prepare -----------------------------------------------------------------

load("data/spatialData")
source("R/01-function.r")

# grade meshblocks into ABC, D, or EFGZ aggregates of their codes
urban.rural <- data.frame(urban.rural = levels(meshblocks@data$urban.rural)
                          , code = c("Z", "G", "B", "A", "D", "F", "E", "C")
                          , grade = c("EFGZ", "EFGZ", "ABC", "ABC", "D", "EFGZ"
                                      , "EFGZ", "ABC"))
urban.rural <- urban.rural[order(urban.rural$code), ] # reorder
meshblocks@data <- join(meshblocks@data, urban.rural, by = "urban.rural")
meshblocks@data$code <- as.character(meshblocks@data$code) # for subsetting by

# legend and colours
ur.legend <- unique(urban.rural$grade)
fillcolours <- brewer.pal(3, "PuOr")


# subset for Wellington Region -------------------------------------------

meshblocksW <- subset(meshblocks, meshblocks@data$RC06D == "Wellington Region")
WList <- dlply(urban.rural
                        , .(grade)
                        , function(x) (subsetMeshblock(as.character(x$grade), meshblocksW))
                        , .progress = "text")

# make one big Palmerston North meshblock to plot first (invisibly) for scale
# otherwise the others might fall off the edge of the plot
WScale <- gBuffer(meshblocksW, width=0, byid=TRUE)
WScale <- unionSpatialPolygons(WScale, rep(1, length(WScale@polygons)))

# plot
png("plots/wellingtonRegion.png", width=420, height=594, units="mm", res=600)
# A3 portrait
plot(WScale, col = NA) # set up coordinates extent
plot(WList$ABC, col = fillcolours[1], lwd = 0.2, add = TRUE)
plot(WList$D, col = fillcolours[2], lwd = 0.2, add = TRUE)
plot(WList$EFGZ, col = fillcolours[3], lwd = 0.2, add = TRUE)
plot(highways500k, lwd = 0.4, col = "red", add = TRUE)
plot(coastline, lwd = 0.4, add = TRUE)
title(main = "Wellington Region")
legend("bottomright", legend = ur.legend, cex = 0.75, fill = fillcolours)
dev.off()


# subset for Manawatu-Wanganui Region ------------------------------------
meshblocksMW <- subset(meshblocks, meshblocks@data$RC06D == "Manawatu-Wanganui Region")
MWList <- dlply(urban.rural
                , .(grade)
                , function(x) (subsetMeshblock(as.character(x$grade), meshblocksMW))
                , .progress = "text")

# make one big Palmerston North meshblock to plot first (invisibly) for scale
# otherwise the others might fall off the edge of the plot
MWScale <- gBuffer(meshblocksMW, width=0, byid=TRUE)
MWScale <- unionSpatialPolygons(MWScale, rep(1, length(MWScale@polygons)))

# plot 
png("plots/manawatuWanganuiRegion.png", width=420, height=594, units="mm", res=600)
# A3 portrait
plot(MWScale, col = NA) # set up coordinates extent
plot(MWList$ABC, col = fillcolours[1], lwd = 0.2, add = TRUE)
plot(MWList$D, col = fillcolours[2], lwd = 0.2, add = TRUE)
plot(MWList$EFGZ, col = fillcolours[3], lwd = 0.2, add = TRUE)
plot(highways500k, lwd = 0.4, col = "red", add = TRUE)
plot(coastline, lwd = 0.4, add = TRUE)
title(main = "Manawatu-Wanganui Region")
legend("bottomright", legend = ur.legend, cex = 0.75, fill = fillcolours)
dev.off()
