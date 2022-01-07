###############################################################################
# Sequence of steps involved in preparing the data
###############################################################################

source("construct-dataset/reshape-data.R")
rm(list = ls())

source("construct-dataset/construct-variables-wnw.R")
rm(list = ls())

source("construct-dataset/construct-variables-screener.R")
rm(list = ls())

source("construct-dataset/construct-variables-baseline.R")
rm(list = ls())

###############################################################################
# Create B=3000 bootstrap samples
###############################################################################

source("bootstrap/boot-mediation-02a.R")
rm(list = ls())

source("bootstrap/boot-mediation-02b.R")
rm(list = ls())

source("bootstrap/boot-mediation-02c.R")
rm(list = ls())



