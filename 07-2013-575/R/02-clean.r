# classify crashes by urban/rural ----------------------------------------
ID <- over(coordinates , meshblocks)
urbanRural <- cbind(coordinates@data$id, ID[, c("MB06", "urban.rural")])
colnames(urbanRural) <- c("crashID", "meshblockID", "urbanRural")
write.table(urbanRural
            , row.names = FALSE
            , col.names = c("crashID", "meshblockID", "urbanRural")
            , file = "output/urbanRural.txt")

# column headings of the other crash datasets ----------------------------
colnames(crashes) <- c("count", "crashid?", "severity", "day", "month", "year", "hour", "stateHighway")

### BoP-crashes.txt
state highway - V8
severity f/s/m/n - V3
day - V4
month - V5
year
hour
crashid


# remove crashes with year = NA (there was one once) ---------------------
crashes <- crashes[!is.na(crashes$year), ]


