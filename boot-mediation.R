library(parallel)
library(dplyr)
library(geeM)
path_output_data <- Sys.getenv("path_output_data")

# Read in functions for data analysis
source("analysis-utils.R")

# Read in data
dat_baseline_analysis <- read.csv(file.path(path_output_data, "dat_baseline_analysis.csv"), header = TRUE)
dat_screener_analysis <- read.csv(file.path(path_output_data, "dat_screener_analysis.csv"), header = TRUE)
dat_wnw_analysis <- read.csv(file.path(path_output_data, "dat_wnw_analysis.csv"), header = TRUE)

# Merge datasets into one data frame
dat_analysis <- left_join(x = dat_wnw_analysis, y = dat_screener_analysis, by = "ParticipantID")
dat_analysis <- left_join(x = dat_analysis, y = dat_baseline_analysis, by = "ParticipantID")
dat_analysis <- dat_analysis %>% select(colnames(dat_screener_analysis), colnames(dat_baseline_analysis), everything())

# Perform resampling of ParticipantID to prepare for bootstrapping
all_participant_ids <- unique(dat_analysis[["ParticipantID"]])
tot_ids <- length(all_participant_ids)

# Total bootstrap samples
set.seed(34901214)
B <- 3000
list_boot <- list()
for(i in 1:B){
  curr_sample <- sample(x = all_participant_ids, size = tot_ids, replace = TRUE)
  list_boot <- append(list_boot, list(curr_sample))
}

# Create bootstrap datasets
list_resampled_data <- list()
for(i in 1:B){
  curr_bootdat <- data.frame(AnalysisID = rep(1:length(list_boot[[i]]), each = 2), ParticipantID = rep(list_boot[[i]], each = 2), time = rep(c(0,1), times = tot_ids))
  curr_bootdat <- left_join(x = curr_bootdat, y = dat_analysis, by = c("ParticipantID", "time"))
  curr_bootdat <- curr_bootdat %>% arrange(AnalysisID, time)
  list_resampled_data <- append(list_resampled_data, list(curr_bootdat))
}


# Center and scale variables in each bootstrap dataset
list_resampled_data_centered_and_scaled <- list()
for(i in 1:B){
  curr_bootdat <- list_resampled_data[[i]]
  curr_bootdat_0 <- curr_bootdat %>% filter(time==0) %>% mutate(across(!c("AnalysisID","ParticipantID","time","survey_timepoint","CASEID","HED","rutgers","sex","race"), scale))
  curr_bootdat_1 <- curr_bootdat %>% filter(time==1) %>% mutate(across(!c("AnalysisID","ParticipantID","time","survey_timepoint","CASEID","HED","rutgers","sex","race"), scale))
  curr_bootdat <- rbind(curr_bootdat_0, curr_bootdat_1)
  curr_bootdat <- curr_bootdat %>% arrange(AnalysisID, time)
  list_resampled_data_centered_and_scaled <- append(list_resampled_data_centered_and_scaled, list(curr_bootdat))
}

remove(curr_bootdat, curr_bootdat_0, curr_bootdat_1)

###############################################################################
# Estimate two models for each bootstrap sample
# Marginal over time and level of DASS
###############################################################################

ncore <- detectCores()
cl <- makeCluster(ncore - 1)
clusterSetRNGStream(cl, 102399)
clusterExport(cl, c("path_output_data"))
clusterEvalQ(cl,
             {
               library(dplyr)
               library(geeM)
               source("analysis-utils.R")  # Read in functions for data analysis
             })

list_models_rutgers <- parLapply(cl=cl, 
                                 X=list_resampled_data_centered_and_scaled, 
                                 fun=function(curr_bootdat){
                                   
                                   fit_rutgers <- geem(rutgers ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                       + qualitative_role_overload + quantitative_role_overload + DASS, 
                                                       data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                                   
                                   fit_DASS <- geem(DASS ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                    + qualitative_role_overload + quantitative_role_overload, 
                                                    data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                                   
                                   tab_rutgers <- FormatGEEOutput(fit_rutgers)
                                   tab_DASS <- FormatGEEOutput(fit_DASS)
                                   
                                   list_models_rutgers <- list(est_rutgers = tab_rutgers, est_DASS = tab_DASS)
                                   
                                   return(list_models_rutgers)
                                 })


list_models_HED <- parLapply(cl=cl, 
                             X=list_resampled_data_centered_and_scaled, 
                             fun=function(curr_bootdat){
                               
                               fit_HED <- geem(HED ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                               + qualitative_role_overload + quantitative_role_overload + DASS, 
                                               data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                               
                               fit_DASS <- geem(DASS ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                + qualitative_role_overload + quantitative_role_overload, 
                                                data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                               
                               tab_HED <- FormatGEEOutput(fit_HED)
                               tab_DASS <- FormatGEEOutput(fit_DASS)
                               
                               list_models_HED <- list(est_HED = tab_HED, est_DASS = tab_DASS)
                               
                               return(list_models_HED)
                             })

stopCluster(cl)

# Save output
list_models_rutgers_01 <- list_models_rutgers
list_models_HED_01 <- list_models_HED

remove(list_models_rutgers, list_models_HED)

save(list_models_rutgers_01, file = "list_models_rutgers_01.RData")
save(list_models_HED_01, file = "list_models_HED_01.RData")

###############################################################################
# Estimate two models for each bootstrap sample
# Conditional over time but marginal over level of DASS
###############################################################################

ncore <- detectCores()
cl <- makeCluster(ncore - 1)
clusterSetRNGStream(cl, 102399)
clusterExport(cl, c("path_output_data"))
clusterEvalQ(cl,
             {
               library(dplyr)
               library(geeM)
               source("analysis-utils.R")  # Read in functions for data analysis
             })

list_models_rutgers <- parLapply(cl=cl, 
                                 X=list_resampled_data_centered_and_scaled, 
                                 fun=function(curr_bootdat){
                                   
                                   fit_rutgers <- geem(rutgers ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                       + time + qualitative_role_overload + quantitative_role_overload  
                                                       + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms
                                                       + DASS + time:DASS, 
                                                       data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                                   
                                   fit_DASS <- geem(DASS ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                    + time + qualitative_role_overload + quantitative_role_overload  
                                                    + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms, 
                                                    data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                                   
                                   tab_rutgers <- FormatGEEOutput(fit_rutgers)
                                   tab_DASS <- FormatGEEOutput(fit_DASS)
                                   
                                   list_models_rutgers <- list(est_rutgers = tab_rutgers, est_DASS = tab_DASS)
                                   
                                   return(list_models_rutgers)
                                 })


list_models_HED <- parLapply(cl=cl, 
                             X=list_resampled_data_centered_and_scaled, 
                             fun=function(curr_bootdat){
                               
                               fit_HED <- geem(HED ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                               + time + qualitative_role_overload + quantitative_role_overload  
                                               + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms
                                               + DASS + time:DASS, 
                                               data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                               
                               fit_DASS <- geem(DASS ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                + time + qualitative_role_overload + quantitative_role_overload  
                                                + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms, 
                                                data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                               
                               tab_HED <- FormatGEEOutput(fit_HED)
                               tab_DASS <- FormatGEEOutput(fit_DASS)
                               
                               list_models_HED <- list(est_HED = tab_HED, est_DASS = tab_DASS)
                               
                               return(list_models_HED)
                             })

stopCluster(cl)

# Save output
list_models_rutgers_02 <- list_models_rutgers
list_models_HED_02 <- list_models_HED

remove(list_models_rutgers, list_models_HED)

save(list_models_rutgers_02, file = "list_models_rutgers_02.RData")
save(list_models_HED_02, file = "list_models_HED_02.RData")

###############################################################################
# Estimate two models for each bootstrap sample
# Conditional over time and level of DASS
###############################################################################

ncore <- detectCores()
cl <- makeCluster(ncore - 1)
clusterSetRNGStream(cl, 102399)
clusterExport(cl, c("path_output_data"))
clusterEvalQ(cl,
             {
               library(dplyr)
               library(geeM)
               source("analysis-utils.R")  # Read in functions for data analysis
             })

list_models_rutgers <- parLapply(cl=cl, 
                                 X=list_resampled_data_centered_and_scaled, 
                                 fun=function(curr_bootdat){
                                   
                                   fit_rutgers <- geem(rutgers ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                       + time + qualitative_role_overload + quantitative_role_overload  
                                                       + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms
                                                       + DASS + I(DASS*DASS) + time:DASS + time:I(DASS*DASS), 
                                                       data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                                   
                                   fit_DASS <- geem(DASS ~ sex + race + age + baseline_rutgers + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                    + time + qualitative_role_overload + quantitative_role_overload  
                                                    + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms, 
                                                    data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                                   
                                   tab_rutgers <- FormatGEEOutput(fit_rutgers)
                                   tab_DASS <- FormatGEEOutput(fit_DASS)
                                   
                                   list_models_rutgers <- list(est_rutgers = tab_rutgers, est_DASS = tab_DASS)
  
                                 return(list_models_rutgers)
                               })


list_models_HED <- parLapply(cl=cl, 
                                 X=list_resampled_data_centered_and_scaled, 
                                 fun=function(curr_bootdat){
                                   
                                   fit_HED <- geem(HED ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                       + time + qualitative_role_overload + quantitative_role_overload  
                                                       + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms
                                                       + DASS + I(DASS*DASS) + time:DASS + time:I(DASS*DASS), 
                                                       data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "quasipoisson")
                                   
                                   fit_DASS <- geem(DASS ~ sex + race + age + baseline_HED + baseline_social_desirability + baseline_impulsivity + lifestress + injunctive_workplace_norms
                                                    + time + qualitative_role_overload + quantitative_role_overload  
                                                    + time:qualitative_role_overload + time:quantitative_role_overload + time:injunctive_workplace_norms, 
                                                    data = curr_bootdat, id = AnalysisID, waves = time, corstr = "exchangeable", family = "gaussian")
                                   
                                   tab_HED <- FormatGEEOutput(fit_HED)
                                   tab_DASS <- FormatGEEOutput(fit_DASS)
                                   
                                   list_models_HED <- list(est_HED = tab_HED, est_DASS = tab_DASS)
                                   
                                   return(list_models_HED)
                                 })

stopCluster(cl)

# Save output
list_models_rutgers_03 <- list_models_rutgers
list_models_HED_03 <- list_models_HED

remove(list_models_rutgers, list_models_HED)

save(list_models_rutgers_03, file = "list_models_rutgers_03.RData")
save(list_models_HED_03, file = "list_models_HED_03.RData")




