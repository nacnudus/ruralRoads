options("scipen"=100) # avoid scientific notation e.g. 10e6 -> 10000000

require(plyr)
require(ggplot2)
require(lubridate)
require(reshape2)
require(stringr)
require(xtable)
require(pander)
require(knitr)
require(grid) # for unit()

source("../R/01-function.r")

# function to facilitate subsetting of data frames by their column class
colClass <- function(DF, colclasses= c("numeric", "integer")) {
  laply(DF, function(vec, test) (class(vec) %in% test), test=colclasses)
}

# function to write to .docx
knitDoc <- function(name) {
  knit(paste0(name, ".Rmd"), encoding = "utf-8")
  system(paste0("pandoc -o ", name, ".docx ", name, ".md"))
}

# for aggregating ethnic groups
ethnicGroup <- read.csv(header = TRUE, 
                        stringsAsFactors = TRUE, 
                        text="ethnicity,ethnicGroup
Asian,Other
Cook Islander,Pacific Peoples
European,European
Fijian,Pacific Peoples
NZ Maori,NZ Maori
Other,Other
Other Pacific Islander,Pacific Peoples
Samoan,Pacific Peoples
Tongan,Pacific Peoples
Unknown,Pacific Peoples
Pacific Islander,Pacific Peoples")

# for aggregating ages
ageGroups <- c("X0.4.Years"
               , "X5.9.Years"
               , "X10.14.Years"
               , "X15.19.Years"
               , "X20.24.Years"
               , "X25.29.Years"
               , "X30.34.Years"
               , "X35.39.Years"
               , "X40.44.Years"
               , "X45.49.Years"
               , "X50.54.Years"
               , "X55.59.Years"
               , "X60.64.Years"
               , "X65.Years.and.Over")
