# Do I get the same meshblocks per crash as my colleague, using GIS?
crashes <- loadCrashes("data/BoP2008-12.csv")
ID <- over(crashes , meshblocks)
crashMeshblockID <- cbind(crashes@data$id ,ID[, c("MB06", "urban.rural")])
write.table(crashMeshblockID
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/crashMeshblockID.txt")
# I compared these with my colleague's spreadsheet in data/discrepancies.xlsx
# and made a table of discrepancies in data/discrepancy.txt.
discrepancy <- read.table("data/discrepancy.txt", header = TRUE)
badcrashes <- crashes[crashes@data$id %in% discrepancy$crashID, ]
qplot(easting, northing, data = as.data.frame(badcrashes))
# get a rough Bay of Plenty meshblock dataset
BoP <- subset(meshblocks, meshblocks@data$RC06D %in% c("Bay of Plenty Region", "Waikato Region"))
plot(badcrashes, col = "red", pch = 16)
plot(BoP, add = TRUE)
# As expected, it's ones close to boundaries.
# I compared in Excel, and very few (6/1000+) changed between urban and rural
# when the various classifications were grouped into urban/rural.