library(readxl)
library(dplyr)

path_screener_data <- Sys.getenv("path_screener_data")  # Location of C2W - Screener - Alldata.xlsx
path_output_data <- Sys.getenv("path_output_data")  # Location of where newly created datasets will be saved

# Read in dataset created by reshape-data.R
wideformat_analysis_ids <- read.csv(file.path(path_output_data, "wideformat_analysis_ids.csv"))

# Read in raw data
screenerdata <- read_xlsx(file.path(path_screener_data, "C2W - Screener - Alldata.xlsx"), sheet = "alldata")

# Drop rows from screenerdata which are not contained in wideformat_analysis_ids
dat_screener_analysis <- left_join(x = wideformat_analysis_ids, y = screenerdata, by = c("ParticipantID"))

# Keep track of new variables constructed
list_new_var_names <- list()

# -----------------------------------------------------------------------------
# Baseline Heavy Episodic Drinking
# -----------------------------------------------------------------------------
dat_screener_analysis <- dat_screener_analysis %>%
  mutate(sq45 = replace(sq45, sq45==99, NA)) %>%
  mutate(baseline_HED = sq45)

curr_new_var <- data.frame(source_raw_dat = "screener", new_var_name = "baseline_HED", min_val = 0, max_val = 25, notable_observations = "HED is equal to the raw value of sq45; Max possible value of HED at screener survey (sq45) and wnw survey (wnw38) are 25 and 30, respectively")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Baseline Rutgers Alcohol Problem Index
# -----------------------------------------------------------------------------
dat_screener_analysis <- dat_screener_analysis %>%
  mutate(sq25 = replace(sq25, sq25==9, NA),
         sq26 = replace(sq26, sq26==9, NA),
         sq27 = replace(sq27, sq27==9, NA),
         sq28 = replace(sq28, sq28==9, NA),
         sq29 = replace(sq29, sq29==9, NA),
         sq30 = replace(sq30, sq30==9, NA),
         sq31 = replace(sq31, sq31==9, NA),
         sq32 = replace(sq32, sq32==9, NA),
         sq33 = replace(sq33, sq33==9, NA),
         sq34 = replace(sq34, sq34==9, NA),
         sq35 = replace(sq35, sq35==9, NA),
         sq36 = replace(sq36, sq36==9, NA),
         sq37 = replace(sq37, sq37==9, NA),
         sq38 = replace(sq38, sq38==9, NA),
         sq39 = replace(sq39, sq39==9, NA),
         sq40 = replace(sq40, sq40==9, NA),
         sq41 = replace(sq41, sq41==9, NA),
         sq42 = replace(sq42, sq42==9, NA),
         sq43 = replace(sq43, sq43==9, NA),
         sq44 = replace(sq44, sq44==9, NA)) %>%
  mutate(sq25 = sq25 - 1,
         sq26 = sq26 - 1,
         sq27 = sq27 - 1,
         sq28 = sq28 - 1,
         sq29 = sq29 - 1,
         sq30 = sq30 - 1,
         sq31 = sq31 - 1,
         sq32 = sq32 - 1,
         sq33 = sq33 - 1,
         sq34 = sq34 - 1,
         sq35 = sq35 - 1,
         sq36 = sq36 - 1,
         sq37 = sq37 - 1,
         sq38 = sq38 - 1,
         sq39 = sq39 - 1,
         sq40 = sq40 - 1,
         sq41 = sq41 - 1,
         sq42 = sq42 - 1,
         sq43 = sq43 - 1,
         sq44 = sq44 - 1) %>%
  mutate(baseline_rutgers = sq25 + sq26 + sq27 + sq28 + sq29 + sq30 + sq31 + sq32 + sq33 + sq34 + sq35 + sq36 + sq37 + sq38 + sq39 + sq40 + sq41 + sq42 + sq43 + sq44)

curr_new_var <- data.frame(source_raw_dat = "screener", new_var_name = "baseline_rutgers", min_val = 0, max_val = 4*20, notable_observations = "Rutgers alcohol problem index is a sum of 20 (sq25-sq44) and 19 (wnw41-wnw59) items respectively when constructed using screener and wnw datasets, respectively. Subtract 1 off raw data values prior to summing when calculating the index")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Sex
# -----------------------------------------------------------------------------
dat_screener_analysis <- dat_screener_analysis %>%
  mutate(sq9 = replace(sq9, sq9==9, NA)) %>%
  mutate(sex = sq9-1)  # Female=1; Male=0

curr_new_var <- data.frame(source_raw_dat = "screener", new_var_name = "sex", min_val = 0, max_val = 1, notable_observations = "Female=1; Male=0; In the screener raw dataset, pGender has missing values while sq9 does not have missing values")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# Sanity check
dat_screener_analysis %>% select(pGender, sq9) %>% apply(., 2, is.na) %>% colSums(.)

# -----------------------------------------------------------------------------
# Race
# -----------------------------------------------------------------------------
dat_screener_analysis <- dat_screener_analysis %>%
  mutate(sq13 = replace(sq13, sq13==9, NA)) %>%
  mutate(race = if_else(sq13==5,1,0))  # White=1; Other=0

curr_new_var <- data.frame(source_raw_dat = "screener", new_var_name = "race", min_val = 0, max_val = 1, notable_observations = "White=1; Other=0; In the screener raw dataset, sq13 does not have missing values")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# Sanity check
dat_screener_analysis %>% select(sq13) %>% apply(., 2, is.na) %>% colSums(.)

# -----------------------------------------------------------------------------
# Age
# -----------------------------------------------------------------------------
dat_screener_analysis <- dat_screener_analysis %>%
  mutate(screener_survey_finish_date = strptime(finishDate, "%m/%d/%Y %H:%M:%S")) %>%
  mutate(screener_survey_finish_month = screener_survey_finish_date$mon+1,
         screener_survey_finish_year = screener_survey_finish_date$year+1900) %>%
  mutate(age = (screener_survey_finish_year + screener_survey_finish_month/12) - (sq4 + sq3/12))

curr_new_var <- data.frame(source_raw_dat = "screener", new_var_name = "age", min_val = 0, max_val = NA, notable_observations = "In the screener raw dataset, archived_age has missing values but self-reported month and year of birth in sq3 and sq4 do not have missing values. Since the timestamp of when the screener survey was completed is recorded and has no missing data, it can be used together with sq3 and sq4 to calculate age of participant")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# Sanity check
dat_screener_analysis %>% select(archived_age, self_reported_age, sq3, sq4, finishDate) %>% apply(., 2, is.na) %>% colSums(.)

# -----------------------------------------------------------------------------
# Wrap up
# -----------------------------------------------------------------------------
dat_new_var_names <- bind_rows(list_new_var_names)

bigdat_screener_analysis <- dat_screener_analysis %>%
  select("ParticipantID", dat_new_var_names[["new_var_name"]], everything())

dat_screener_analysis <- dat_screener_analysis %>%
  select("ParticipantID", dat_new_var_names[["new_var_name"]])


write.csv(dat_new_var_names, file.path(path_output_data, "dat_screener_vars.csv"), row.names = FALSE)
write.csv(dat_screener_analysis, file.path(path_output_data, "dat_screener_analysis.csv"), row.names = FALSE)
write.csv(bigdat_screener_analysis, file.path(path_output_data, "bigdat_screener_analysis.csv"), row.names = FALSE)

