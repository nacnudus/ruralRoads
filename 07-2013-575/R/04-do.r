# load crashMeshblocks - this will only exist if the relevant code in
# 02-clean.r has been run, but try to avoid that.
crashMeshblocks <- read.table("output/crashMeshblockID.txt"
                              , header = TRUE
                              , quote = "\"")

# join coordinates to meshblocks to urban/rural to crashes
crashes2 <- join(coordinates@data, crashMeshblocks, type = "inner")
crashes2 <- join(crashes2, meshblockUrban, by = "meshblockID", type = "inner")
crashes2 <- join(crashes2, crashes, type = "inner")

# define urban as A:D
crashes2$urban <- as.character(crashes2$code) <= "D"

ggplot(crashes2[!is.na(crashes2$hour), ]
       , aes(hour, group = urban, fill = urban)) + 
  geom_density(alpha = 0.2) +
  facet_grid(severity ~ stateHighway, margins = TRUE)