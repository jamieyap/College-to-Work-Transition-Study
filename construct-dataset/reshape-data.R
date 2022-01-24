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

# Note: participants_all would be the complete list of participant ID's who were sent a wnw survey
participants_all <- unique(refdata[["ParticipantID"]])
# How many participants are there in the wnwdataset?
length(participants_all)

participants_with_miss <- wnwdata %>% filter(is.na(wnw1)) %>% select(ParticipantID) %>% unique(.) %>% .[["ParticipantID"]]
participants_with_nomiss <- setdiff(participants_all, participants_with_miss)

# Check if ID's within participants_with_miss are also within participants_with_nomiss
# Output:
# > sum(participants_with_miss %in% participants_with_nomiss)
# [1] 0

sum(participants_with_miss %in% participants_with_nomiss)

###############################################################################
# Investigate participants having missing wnw1 values
###############################################################################

# Inspect wnwi, an item where participants were asked to confirm whether 
# they indeed graduated already
# Note: no missing values in wnwi
summary(wnwdata$wnwi)

# Take the subset of data corresponding to those participants whose
# ID's are within participants_with_miss
tmpdat <- wnwdata %>% 
  filter(ParticipantID %in% participants_with_miss) %>% 
  select(wnwi, wnw1, ParticipantID, Timepoint, everything()) %>%
  arrange(ParticipantID, Timepoint)

# These participants may not have any value for wnw1 since they
# reported to not have graduated in wnwi (i.e., they have wnwi=2)
# Let's confirm whether this is the case.

# First, separate tmpdat into two smaller data frames.
# tmp_dat_more_than_one are those rows corresponding to ParticipantID's which
# have appeared more than once in tmpdat
more_than_one <- duplicated(tmpdat$ParticipantID)
tmpdat_more_than_one <- tmpdat %>%
  filter(more_than_one) %>%
  arrange(ParticipantID, Timepoint)

# tmp_dat_exactly_one are those rows corresponding to ParticipantID's which
# have appeared exactly once in tmpdat
tmpdat_exactly_one <- tmpdat %>% 
  filter(!(ParticipantID %in% unique(tmpdat_more_than_one$ParticipantID)))

remove(tmpdat)

dat_did_not_graduate <- rbind(tmpdat_more_than_one, tmpdat_exactly_one)
dat_did_not_graduate <- dat_did_not_graduate %>% select(ParticipantID, Timepoint, wnwi, wnw1)

write.csv(dat_did_not_graduate, file.path(path_output_data, "dat_did_not_graduate.csv"), row.names = FALSE)

###############################################################################
# Investigate participants having no missing wnw1 values
###############################################################################

# All these participants always report wnwi=1 (they confirmed that they
# graduated)
# ID's are within participants_with_miss
tmpdat <- wnwdata %>% 
  filter(ParticipantID %in% participants_with_nomiss)

summary(tmpdat$wnwi)

remove(tmpdat)

###############################################################################
# Begin data preparation for participants having no missing wnw1 values
###############################################################################
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

###############################################################################
# Finally, create data frame having an indicator for whether individual will be
# included in analysis
###############################################################################

dat_exclusion_rule <- bind_rows(list_exclusion_rule)
check_include1 <- (dat_exclusion_rule[["begin_month_wnw1"]]==1 | dat_exclusion_rule[["begin_month_wnw1"]]==3 | dat_exclusion_rule[["begin_month_wnw1"]]==5)
check_include2 <- (dat_exclusion_rule[["post_begin_month_wnw1"]]==1 | dat_exclusion_rule[["post_begin_month_wnw1"]]==3 | dat_exclusion_rule[["post_begin_month_wnw1"]]==5)
dat_exclusion_rule[["include"]] <- if_else(check_include1 & check_include2, 1, 0)
dat_exclusion_rule[["include"]] <- replace(dat_exclusion_rule[["include"]], is.na(dat_exclusion_rule[["include"]]), 0)

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
# 1,614 unique participant IDs in dat_exclusion_rule.csv
write.csv(dat_exclusion_rule, file.path(path_output_data, "dat_exclusion_rule.csv"), row.names = FALSE)

# 1,240 unique participant IDs in both csv files below
write.csv(long_subset_dat_exclusion_rule, file.path(path_output_data, "longformat_analysis_ids.csv"), row.names = FALSE)
write.csv(wide_subset_dat_exclusion_rule, file.path(path_output_data, "wideformat_analysis_ids.csv"), row.names = FALSE)

