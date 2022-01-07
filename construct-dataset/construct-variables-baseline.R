library(readxl)
library(dplyr)

path_baseline_data <- Sys.getenv("path_baseline_data")  # Location of C2W- Baseline - Alldata.xlsx
path_output_data <- Sys.getenv("path_output_data")  # Location of where newly created datasets will be saved

# Read in dataset created by reshape-data.R
wideformat_analysis_ids <- read.csv(file.path(path_output_data, "wideformat_analysis_ids.csv"))

# Read in raw data
baselinedata <- read_xlsx(file.path(path_baseline_data, "C2W- Baseline - Alldata.xlsx"), sheet = "Alldata")

# Drop rows from baselinedata which are not contained in wideformat_analysis_ids
dat_baseline_analysis <- left_join(x = wideformat_analysis_ids, y = baselinedata, by = c("ParticipantID"))

# Keep track of new variables constructed
list_new_var_names <- list()

# -----------------------------------------------------------------------------
# Baseline Social Desirability
# -----------------------------------------------------------------------------
dat_baseline_analysis <- dat_baseline_analysis %>%
  mutate(bq62 = replace(bq62, bq62==9, NA),
         bq63 = replace(bq63, bq63==9, NA),
         bq64 = replace(bq64, bq64==9, NA),
         bq65 = replace(bq65, bq65==9, NA),
         bq66 = replace(bq66, bq66==9, NA),
         bq67 = replace(bq67, bq67==9, NA),
         bq68 = replace(bq68, bq68==9, NA),
         bq69 = replace(bq69, bq69==9, NA),
         bq70 = replace(bq70, bq70==9, NA),
         bq71 = replace(bq71, bq71==9, NA)) %>%
  mutate(baseline_social_desirability = bq62 + bq63 + bq64 + bq65 + bq66 + bq67 + bq68 + bq69 + bq70 + bq71)

curr_new_var <- data.frame(source_raw_dat = "baseline", new_var_name = "baseline_social_desirability", min_val = 0, max_val = 1*10, notable_observations = "Baseline social desirability is the raw sum of bq62-bq71")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Baseline Impulsivity
# -----------------------------------------------------------------------------
dat_baseline_analysis <- dat_baseline_analysis %>%
  mutate(bq51 = replace(bq51, bq51==9, NA),
         bq52 = replace(bq52, bq52==9, NA),
         bq53 = replace(bq53, bq53==9, NA),
         bq54 = replace(bq54, bq54==9, NA)) %>%
  mutate(bq51 = bq51 - 1,
         bq52 = bq52 - 1,
         bq53 = bq53 - 1,
         bq54 = bq54 - 1) %>%
  mutate(baseline_impulsivity = (bq51+bq52+bq53+bq54)/4)

curr_new_var <- data.frame(source_raw_dat = "baseline", new_var_name = "baseline_impulsivity", min_val = 0, max_val = 3, notable_observations = "Subtract 1 off bq51-bq54 before obtaining their average to calculate baseline impulsivity")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Wrap up
# -----------------------------------------------------------------------------
dat_new_var_names <- bind_rows(list_new_var_names)

bigdat_baseline_analysis <- dat_baseline_analysis %>%
  select("ParticipantID", dat_new_var_names[["new_var_name"]], everything())

dat_baseline_analysis <- dat_baseline_analysis %>%
  select("ParticipantID", dat_new_var_names[["new_var_name"]])


write.csv(dat_new_var_names, file.path(path_output_data, "dat_baseline_vars.csv"), row.names = FALSE)
write.csv(dat_baseline_analysis, file.path(path_output_data, "dat_baseline_analysis.csv"), row.names = FALSE)
write.csv(bigdat_baseline_analysis, file.path(path_output_data, "bigdat_baseline_analysis.csv"), row.names = FALSE)


