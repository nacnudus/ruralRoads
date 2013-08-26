options("scipen"=100) # avoid scientific notation e.g. 10e6 -> 10000000

require(plyr)
require(ggplot2)
require(lubridate)
require(reshape2)
require(stringr)

source("../R/01-function.r")

# function to facilitate subsetting of data frames by their column class
colClass <- function(DF, colclasses= c("numeric", "integer")) {
  laply(DF, function(vec, test) (class(vec) %in% test), test=colclasses)
}
