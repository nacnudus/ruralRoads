require(reshape2)
require(ggplot2)
require(RColorBrewer)
require(ggthemes)

meshblockData <- read.table("output/meshblockData.txt", header = TRUE)

# sort north/south
meshblockData$policeDistrict <- factor(meshblockData$policeDistrict
                                       , levels=c("NORTHLAND"
                                                  , "WAITEMATA"
                                                  , "AUCKLAND CITY"
                                                  , "COUNTIES/MANUKAU"
                                                  , "WAIKATO"
                                                  , "BAY OF PLENTY"
                                                  , "EASTERN"
                                                  , "CENTRAL"
                                                  , "WELLINGTON"
                                                  , "TASMAN"
                                                  , "CANTERBURY"
                                                  , "SOUTHERN"))

# interesting columns
x <- meshblockData[!is.na(meshblockData$urbanRural), c("policeDistrict", "urbanRural", "road", "highway")]

y <- melt(x, id.vars=c("policeDistrict", "urbanRural"))

# four kinds of roads: urban/rural by road/highway
y$urrh <- paste(y$urbanRural, y$variable)
# sort by prevelance (by observation!)
y$urrh <- factor(y$urrh, levels <- c("rural road", "urban road", "rural highway", "urban highway"))

# table
dcast(y, policeDistrict + urrh ~ variable, sum, na.rm=TRUE)

# plot

ggplot(y, aes(policeDistrict, weight=value, group=urrh, fill=urrh)) + geom_bar(position="dodge") +
  scale_fill_brewer(palette="Set2") +
  theme_bw() + theme(legend.position="bottom", legend.title=element_blank()
                     , axis.text.x=element_text(angle=90, hjust=1, vjust=0.5)
                     , axis.text.y=element_text(angle=90, hjust=1, vjust=0.5)) +
  xlab(NULL) +
  ylab("1000 km") +
  ggtitle("Road Length")
