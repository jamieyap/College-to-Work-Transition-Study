library(readxl)
library(dplyr)

# Set file paths: 
# To change file paths, one can, for example, simply change the line
# path_wnw_data <- Sys.getenv("path_wnw_data")
# to the line (note the back slash, instead of a foward slash)
# path_wnw_data <- "C:/Users/myusername/Desktop"

path_wnw_data <- Sys.getenv("path_wnw_data")  # Location of C2W - Working Not Working - Alldata.xlsx
path_output_data <- Sys.getenv("path_output_data")  # Location of where newly created datasets will be saved

# Read in raw data
wnwdata <- read_xlsx(file.path(path_wnw_data, "C2W - Working Not Working - Alldata.xlsx"), sheet = "alldata")

# Ensure rows are correctly ordered according to ParticipantID and survey_timepoint
refdata <- wnwdata %>% select(ParticipantID, survey_timepoint, wnw1) %>% arrange(ParticipantID, survey_timepoint)

# For each participant, determine the first time ever (if any) they reported to have worked full time
# Do this in two parts: first, for participants who do not have any missing data in wnw1
# second, for participants who have any missing data in wnw1

participants_all <- unique(refdata[["ParticipantID"]])
participants_with_miss <- wnwdata %>% filter(is.na(wnw1)) %>% select(ParticipantID) %>% unique(.) %>% .[["ParticipantID"]]
participants_with_nomiss <- setdiff(participants_all, participants_with_miss)

# Begin data preparation for participants having no missing wnw1 values
list_with_begin_month_participants <- list()
list_exclusion_rule <- list()

for(i in 1:length(participants_with_nomiss)){
  curr_participant_id <- participants_with_nomiss[i]
  curr_dat <- refdata %>% filter(ParticipantID == curr_participant_id)
  full_time_idx <- which((curr_dat[["wnw1"]]==1) | (curr_dat[["wnw1"]]==3) | (curr_dat[["wnw1"]]==5))
  
  if(length(full_time_idx)==0){
    # these are the participants who never reported to have worked full time, ever
    tmpdat <- data.frame(ParticipantID=curr_participant_id, 
                         any_ft = 0, 
                         begin_month = NA, post_begin_month = NA, 
                         begin_month_wnw1 = NA, post_begin_month_wnw1 = NA)
    list_exclusion_rule <- append(list_exclusion_rule, list(tmpdat))
  }else{
    # these are the participants who have reported to have worked full time at least once during the course of the study
    list_with_begin_month_participants <- append(list_with_begin_month_participants, curr_participant_id)
    this_idx <- min(full_time_idx)
    # update record of how exclusion criteria applied to a participant
    tmpdat <- data.frame(ParticipantID=curr_participant_id, 
                         any_ft = 1, 
                         begin_month = curr_dat[this_idx,][["survey_timepoint"]], post_begin_month = NA, 
                         begin_month_wnw1 = curr_dat[this_idx,][["wnw1"]], post_begin_month_wnw1 = NA)
    list_exclusion_rule <- append(list_exclusion_rule, list(tmpdat))
  }
}

dat_exclusion_rule <- bind_rows(list_exclusion_rule)

# We now need to determine whether participants were working full time
# twelve months after they first reported to have worked full time
for(i in 1:nrow(dat_exclusion_rule)){
  if(dat_exclusion_rule[i,][["any_ft"]]==1){
    curr_participant_id <- dat_exclusion_rule[i,][["ParticipantID"]]
    curr_begin_month <- dat_exclusion_rule[i,][["begin_month"]]
    curr_post_begin_month <- curr_begin_month + 12
    curr_dat <- refdata %>% filter(ParticipantID==curr_participant_id & survey_timepoint==curr_post_begin_month)
    if(nrow(curr_dat)==0){
      list_exclusion_rule[[i]][["post_begin_month"]] <- curr_post_begin_month
      list_exclusion_rule[[i]][["post_begin_month_wnw1"]] <- NA
    }else{
      curr_post_begin_wnw1 <- curr_dat %>% select(wnw1) %>% .[["wnw1"]]
      list_exclusion_rule[[i]][["post_begin_month"]] <- curr_post_begin_month
      list_exclusion_rule[[i]][["post_begin_month_wnw1"]] <- curr_post_begin_wnw1
    }
  }
}

# Now, work with participant ID's in participants_with_miss
tab_count <- refdata %>% filter(ParticipantID %in% participants_with_miss) %>% 
  group_by(ParticipantID) %>% summarise(count_row=n())

# which participant only had one row?
miss_ids_1 <- tab_count %>% filter(count_row==1) %>% select(ParticipantID) %>% .[["ParticipantID"]]

for(i in 1:length(miss_ids_1)){
  curr_participant_id <- miss_ids_1[i]
  # update record of how exclusion criteria applied to a participant
  tmpdat <- data.frame(ParticipantID=curr_participant_id, 
                       any_ft = NA, 
                       begin_month = NA, post_begin_month = NA, 
                       begin_month_wnw1 = NA, post_begin_month_wnw1 = NA)
  list_exclusion_rule <- append(list_exclusion_rule, list(tmpdat))
}

# which participant had two or more rows?
miss_ids_2 <- tab_count %>% filter(count_row>1) %>% select(ParticipantID) %>% .[["ParticipantID"]]

# View data; only three participants
#refdata %>% filter(ParticipantID %in% miss_ids_2)

for(i in 1:length(miss_ids_2)){
  if(i==1){
    curr_participant_id <- miss_ids_2[i]
    # update record of how exclusion criteria applied to a participant
    tmpdat <- data.frame(ParticipantID=curr_participant_id, 
                         any_ft = NA, 
                         begin_month = NA, post_begin_month = NA, 
                         begin_month_wnw1 = NA, post_begin_month_wnw1 = NA)
    list_exclusion_rule <- append(list_exclusion_rule, list(tmpdat))
  }else{
    curr_participant_id <- miss_ids_2[i]
    curr_dat <- refdata %>% filter(ParticipantID == curr_participant_id)
    full_time_idx <- which((curr_dat[["wnw1"]]==1) | (curr_dat[["wnw1"]]==3) | (curr_dat[["wnw1"]]==5))
    # update record of how exclusion criteria applied to a participant
    this_idx <- min(full_time_idx)
    tmpdat <- data.frame(ParticipantID=curr_participant_id, 
                         any_ft = 1, 
                         begin_month = curr_dat[this_idx,][["survey_timepoint"]], post_begin_month = curr_dat[this_idx,][["survey_timepoint"]]+12, 
                         begin_month_wnw1 = curr_dat[this_idx,][["wnw1"]], post_begin_month_wnw1 = NA)
    list_exclusion_rule <- append(list_exclusion_rule, list(tmpdat))
  }
}

# Finally, create data frame having an indicator for whether individual will be included in analysis
dat_exclusion_rule <- bind_rows(list_exclusion_rule)
check_include1 <- (dat_exclusion_rule[["begin_month_wnw1"]]==1 | dat_exclusion_rule[["begin_month_wnw1"]]==3 | dat_exclusion_rule[["begin_month_wnw1"]]==5)
check_include2 <- (dat_exclusion_rule[["post_begin_month_wnw1"]]==1 | dat_exclusion_rule[["post_begin_month_wnw1"]]==3 | dat_exclusion_rule[["post_begin_month_wnw1"]]==5)
dat_exclusion_rule[["include"]] <- if_else(check_include1 & check_include2, 1, 0)
dat_exclusion_rule[["include"]] <- replace(dat_exclusion_rule[["include"]], is.na(dat_exclusion_rule[["include"]]), 0)

# Account for those participants who will be excluded from all data analysis
# ex1: 32-did not report at least one value for wnw1; 1-reported to not be working full time twice and had missing value for wnw1 on last available assessment
# ex2: reported at least one value for wnw1; but in all cases, reported to not be working full time
# ex3: twelve months after having reported to be working full time, no indication of whether the individual worked full time (no reported value for wnw1 twelve months after first reporting wnw1=1,3,5)
# ex4: twelve months after having reported to be working full time, reported to not be working full time (reported a value of wnw1, but wnw1 is not 1,3 or 5)
tabulate_excluded_by_source <- dat_exclusion_rule %>% 
  summarise(ex1 = sum(is.na(any_ft)),
            ex2 = sum(any_ft==0, na.rm=TRUE),
            ex3 = sum(any_ft==1 & is.na(post_begin_month_wnw1), na.rm=TRUE),
            ex4 = sum(any_ft==1 & !is.na(post_begin_month_wnw1) & (!(post_begin_month_wnw1==1 | post_begin_month_wnw1==3 | post_begin_month_wnw1==5)), na.rm=TRUE))

tabulate_excluded_by_source[["total_excluded"]] <- rowSums(tabulate_excluded_by_source)
print(tabulate_excluded_by_source) 

# The data frame dat_exclusion_rule contains the following columns
# ParticipantID -- unique identifier for each participant
# any_ft -- did the individual report to have worked full time at any point in the study? (1) yes; (0) no; (NA) if no indication either way
# begin_month -- which was the very first month (i.e., after graduating from college) the individual reported to have worked full time? e.g., '3' represents 3 months after graduating from college
# post_begin_month -- equal to begin_month plus 12 months
# begin_month_wnw1 -- what was the value of wnw1 reported at begin_month? (if any_ft=1, possible values are 1,3,5; if any_ft=0, this variable is set to NA)
# post_begin_month_wnw1 -- what was the value of wnw1 reported at post_begin_month_wnw1? (regardless of the value of any_ft, possible values are 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
# include -- whether individual will be included (1) or not (0) in data analysis

# Sanity check: count number of individuals having each possible combination of values of wnw1 reported
# during begin_month_wnw1 and post_begin_month_wnw1
dat_exclusion_rule %>% filter(include==1) %>% group_by(begin_month_wnw1, post_begin_month_wnw1) %>% summarise(n())

# Select those rows in wnwdata corresponding to individuals who will be included in data analysis
# To determine which participants to include in data analysis, simply obtain those rows having include=1
# Among those rows having include=1, 'time 0' is the value of begin_month and 'time 1' is the value of post_begin_month
wide_subset_dat_exclusion_rule <- dat_exclusion_rule %>% 
  filter(include==1) %>%
  select(ParticipantID, begin_month, post_begin_month) %>%
  rename(survey_timepoint_0 = begin_month,
         survey_timepoint_1 = post_begin_month)

long_subset_dat_exclusion_rule <- reshape(data = wide_subset_dat_exclusion_rule, 
                                          direction = "long", 
                                          idvar = "ParticipantID", 
                                          varying = list(c("survey_timepoint_0","survey_timepoint_1")), 
                                          v.names = "survey_timepoint")

long_subset_dat_exclusion_rule <- long_subset_dat_exclusion_rule %>%
  arrange(ParticipantID, time) %>%
  mutate(time = time-1)

# Write output to csv file
write.csv(dat_exclusion_rule, file.path(path_output_data, "dat_exclusion_rule.csv"), row.names = FALSE)
write.csv(long_subset_dat_exclusion_rule, file.path(path_output_data, "longformat_analysis_ids.csv"), row.names = FALSE)
write.csv(wide_subset_dat_exclusion_rule, file.path(path_output_data, "wideformat_analysis_ids.csv"), row.names = FALSE)


