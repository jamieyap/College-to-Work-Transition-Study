library(readxl)
library(dplyr)

path_wnw_data <- Sys.getenv("path_wnw_data")  # Location of C2W - Working Not Working - Alldata.xlsx
path_output_data <- Sys.getenv("path_output_data")  # Location of where newly created datasets will be saved

# Read in dataset created by reshape-data.R
longformat_analysis_ids <- read.csv(file.path(path_output_data, "longformat_analysis_ids.csv"))

# Read in raw data
wnwdata <- read_xlsx(file.path(path_wnw_data, "C2W - Working Not Working - Alldata.xlsx"), sheet = "alldata")

# Drop rows from wnwdata which are not contained in longformat_analysis_ids
dat_wnw_analysis <- left_join(x = longformat_analysis_ids, y = wnwdata, by = c("ParticipantID", "survey_timepoint"))

# Keep track of new variables constructed
list_new_var_names <- list()

# -----------------------------------------------------------------------------
# Life Stress
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw12 = wnw12 - 1,
         wnw13 = wnw13 - 1,
         wnw14 = wnw14 - 1,
         qwnw15 = qwnw15 - 1) %>%
  mutate(lifestress = (wnw12 + wnw13 + wnw14 + qwnw15)/4)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = c("lifestress"), min_val = 0, max_val = 4, notable_observations = "Subtract 1 off wnw12, wnw13, wnw14, and qwnw15 prior to obtaining their average to calculate life stress")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Heavy Episodic Drinking
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw38 = replace(wnw38, wnw38==99, NA)) %>%
  mutate(HED = wnw38)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = "HED", min_val = 0, max_val = 30, notable_observations = "HED is equal to the raw value of wnw38; Max possible value of HED at screener survey (sq45) and wnw survey (wnw38) are 25 and 30, respectively")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Rutgers Alcohol Problem Index 
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw41 = replace(wnw41, wnw41==9, NA),
         wnw42 = replace(wnw42, wnw42==9, NA),
         wnw43 = replace(wnw43, wnw43==9, NA),
         wnw44 = replace(wnw44, wnw44==9, NA),
         wnw45 = replace(wnw45, wnw45==9, NA),
         wnw46 = replace(wnw46, wnw46==9, NA),
         wnw47 = replace(wnw47, wnw47==9, NA),
         wnw48 = replace(wnw48, wnw48==9, NA),
         wnw49 = replace(wnw49, wnw49==9, NA),
         wnw50 = replace(wnw50, wnw50==9, NA),
         wnw51 = replace(wnw51, wnw51==9, NA),
         wnw52 = replace(wnw52, wnw52==9, NA),
         wnw53 = replace(wnw53, wnw53==9, NA),
         wnw54 = replace(wnw54, wnw54==9, NA),
         wnw55 = replace(wnw55, wnw55==9, NA),
         wnw56 = replace(wnw56, wnw56==9, NA),
         wnw57 = replace(wnw57, wnw57==9, NA),
         wnw58 = replace(wnw58, wnw58==9, NA),
         wnw59 = replace(wnw59, wnw59==9, NA)) %>%
  mutate(wnw41 = wnw41 - 1,
         wnw42 = wnw42 - 1,
         wnw43 = wnw43 - 1,
         wnw44 = wnw44 - 1,
         wnw45 = wnw45 - 1,
         wnw46 = wnw46 - 1,
         wnw47 = wnw47 - 1,
         wnw48 = wnw48 - 1,
         wnw49 = wnw49 - 1,
         wnw50 = wnw50 - 1,
         wnw51 = wnw51 - 1,
         wnw52 = wnw52 - 1,
         wnw53 = wnw53 - 1,
         wnw54 = wnw54 - 1,
         wnw55 = wnw55 - 1,
         wnw56 = wnw56 - 1,
         wnw57 = wnw57 - 1,
         wnw58 = wnw58 - 1,
         wnw59 = wnw59 - 1) %>%
  mutate(rutgers = wnw41 + wnw42 + wnw43 + wnw44 + wnw45 + wnw46 + wnw47 + wnw48 + wnw49 + wnw50 + wnw51 + wnw52 + wnw53 + wnw54 + wnw55 + wnw56 + wnw57 + wnw58 + wnw59)

dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(summed_drinking_vars = wnw39a+wnw39b+wnw39c+wnw39d+wnw39e+wnw39f+wnw39g+wnw40) %>%
  mutate(condition = 0) %>%
  mutate(condition = replace(condition, is.na(rutgers) & summed_drinking_vars==0, 1))


curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = "rutgers", min_val = 0*19, max_val = 4*19, notable_observations = "Rutgers alcohol problem index is a sum of 20 (sq25-sq44) and 19 (wnw41-wnw59) items respectively when constructed using screener and wnw datasets, respectively. Subtract 1 off raw data values prior to summing when calculating the index")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Qualitative Role Overload
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw82 = replace(wnw82, wnw82==9, NA),
         wnw83 = replace(wnw83, wnw83==9, NA),
         wnw84 = replace(wnw84, wnw84==9, NA)) %>%
  mutate(wnw82 = wnw82 - 1,
         wnw83 = wnw83 - 1,
         wnw84 = wnw84 - 1) %>%
  mutate(qualitative_role_overload = (wnw82+wnw83+wnw84)/3)
  
curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = "qualitative_role_overload", min_val = 0, max_val = 6, notable_observations = "Subtract 1 off wnw82-wnw84 prior to obtaining their average to calculate qualitative role overload")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Quantitative Role Overload
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw85 = replace(wnw85, wnw85==99, NA)) %>%
  mutate(quantitative_role_overload = wnw85)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = "quantitative_role_overload", min_val = 0, max_val = 30, notable_observations = "Quantitative role overload is equal to raw value of wnw85")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Injunctive Workplace Drinking Norms
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw111 = replace(wnw111, (wnw111==9) | (wnw111==6), NA),
         wnw114 = replace(wnw114, (wnw114==9) | (wnw114==6), NA)) %>%
  mutate(wnw111 = wnw111 - 1,
         wnw114 = wnw114 - 1) %>%
  mutate(injunctive_workplace_norms = (wnw111+wnw114)/2)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = c("wnw111","wnw114","injunctive_workplace_norms"), min_val = 0, max_val = 4, notable_observations = "Subtract 1 off wnw111 and wnw114 prior to obtaining their average to calculate injunctive workplace drinking norms")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Descriptive Workplace Drinking Norms
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw116 = replace(wnw116, wnw116==9, NA),
         wnw117 = replace(wnw117, wnw117==9, NA)) %>%
  mutate(wnw116 = wnw116 - 1,
         wnw117 = wnw117 - 1) %>%
  mutate(descriptive_workplace_norms = (wnw116+wnw117)/2)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = c("wnw116","wnw117","descriptive_workplace_norms"), min_val = 0, max_val = 4, notable_observations = "Subtract 1 off wnw116 and wnw117 prior to obtaining their average to calculate descriptive workplace drinking norms")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Psychological Distress
# -----------------------------------------------------------------------------
dat_wnw_analysis <- dat_wnw_analysis %>%
  mutate(wnw28 = replace(wnw28, wnw28==9, NA),
         wnw29 = replace(wnw29, wnw29==9, NA),
         wnw30 = replace(wnw30, wnw30==9, NA),
         wnw31 = replace(wnw31, wnw31==9, NA),
         wnw32 = replace(wnw32, wnw32==9, NA)) %>%
  mutate(DASS = wnw28 + wnw29 + wnw30 + wnw31 + wnw32)

curr_new_var <- data.frame(source_raw_dat = "wnw", new_var_name = "DASS", min_val = 0, max_val = 3*5, notable_observations = "Psychological distress is the raw sum of wnw28-wnw32")
list_new_var_names <- append(list_new_var_names, list(curr_new_var))

# -----------------------------------------------------------------------------
# Wrap up
# -----------------------------------------------------------------------------
dat_new_var_names <- bind_rows(list_new_var_names)

bigdat_wnw_analysis <- dat_wnw_analysis %>%
  select("ParticipantID", "time", "survey_timepoint", "CASEID", "condition", dat_new_var_names[["new_var_name"]], everything())

dat_wnw_analysis <- dat_wnw_analysis %>%
  select("ParticipantID", "time", "survey_timepoint", "CASEID", "condition", dat_new_var_names[["new_var_name"]])

dat_new_var_names <- dat_new_var_names %>% filter(!(new_var_name %in% c("wnw111","wnw114","wnw116","wnw117")))
dat_wnw_analysis <- dat_wnw_analysis %>% select(-wnw111, -wnw114, -wnw116, -wnw117)

write.csv(dat_new_var_names, file.path(path_output_data, "dat_wnw_vars.csv"), row.names = FALSE)
write.csv(dat_wnw_analysis, file.path(path_output_data, "dat_wnw_analysis.csv"), row.names = FALSE)
write.csv(bigdat_wnw_analysis, file.path(path_output_data, "bigdat_wnw_analysis.csv"), row.names = FALSE)

