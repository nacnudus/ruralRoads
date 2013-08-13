07-2013-575
===========
Bay of Plenty drink-driving
---------------------------

This is an analysis of alcohol-related crashes in the Bay of Plenty district.

It only uses so much code as will identify the meshblock each crash took place in and what urban/rural category that meshblock is.  Meshblock and urban/rural concordance data is sourced from ruralRoads/data.  Data specific to this analysis, i.e. crashes (from CAS), is in the data directory within this analysis.  R code is in the R directory within this analysis.

Initialize from a new instance in Amazon EC2.
---------------------------------------------
1.  Clone the ruralRoads repository in github.
(https://github.com/nacnudus/ruralRoads)

1.  `setwd()` into the ruralRoads directory.

1.  Load some workspace data (more efficient than recalculating it.)
`load("data/spatialData")

1.  `source("R/01-function.r")`

1.  `setwd("./07-2013-575")` into this analysis.

1.  Use the R scripts in the R directory of this analysis (i.e. 07-2013-575/R/).
