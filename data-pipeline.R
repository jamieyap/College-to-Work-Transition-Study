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

