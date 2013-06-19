require(ggplot2)
require(mapproj)
require(maptools)

# MB06_LV2.shp crashes the EC2 free tier instance,
# so using REGC06_LV2.shp for testing.

# xx<- readShapePoly("/home/nacnudus/R/rural_roads/data/MB06_LV2.shp"
#                    , IDvar="MB06"
#                    , proj4string=CRS("++proj=nzmg +lat_0=-41.0 +lon_0=173.0 +x_0=2510000.0 +y_0=6023150.0 +ellps=intl +units=m"
#                    )
# )

xx<- readShapePoly("/home/nacnudus/R/rural_roads/data/REGC06_LV2.shp"
                   , IDvar="REGC_NO"
                   , proj4string=CRS("++proj=nzmg +lat_0=-41.0 +lon_0=173.0 +x_0=2510000.0 +y_0=6023150.0 +ellps=intl +units=m"
                   )
)

xy <- fortify(xx)
ggplot(data=xy, aes(long, lat, group=group)) + 
  geom_polygon(colour='black',
               fill='white') +
  theme_bw()
# + coord_map() crashes the EC2 free tier instance.

# This is the simplest method, as Hadley points out.
# But you could also continue as suggested on the mailing list.

allcoordinates = function(x) {
  ret = NULL
  polys = x at polygons
  for(i in 1:length(polys)) {
    pp = polys[[i]]@Polygons
    for (j in 1:length(pp))
      ret = rbind(ret, coordinates(pp[[j]]))
  }
  ret
}

allcoordinates_lapply = function(x) {
  polys = x at polygons
  return(do.call("rbind", lapply(polys, function(pp) {
    do.call("rbind", lapply(pp at Polygons, coordinates))
  })))
}

q = allcoordinates(xx)
z = allcoordinates_lapply(xx)
all.equal(q,z)