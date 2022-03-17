library(dplyr)

###############################################################################
# Tables for the regression models: RAPI
###############################################################################

injunctive_model_01 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_01.csv") %>% select(-p)
injunctive_model_02 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_02.csv") %>% select(-p)
injunctive_model_03 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_03.csv") %>% select(-p)
injunctive_model_05 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_04.csv") %>% select(-p)
injunctive_model_07 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_05.csv") %>% select(-p)


all_models <- full_join(x = injunctive_model_01, y = injunctive_model_02, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_03, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_05, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_07, by = "parameter")

colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=5))

print(all_models)
write.csv(all_models, "prepare-publication-tables/RAPI/injunctive_RAPI.csv", na = "")

injunctive_model_04 <- read.csv("prepare-publication-tables/DASS/baseline_RAPI_model_06.csv") %>% select(-p)
injunctive_model_06 <- read.csv("prepare-publication-tables/DASS/baseline_RAPI_model_07.csv") %>% select(-p)
all_models <- full_join(x = injunctive_model_04, y = injunctive_model_06, by = "parameter")
colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=2))

print(all_models)
write.csv(all_models, "prepare-publication-tables/DASS/baseline_RAPI.csv", na = "")

###############################################################################
# Tables for the regression models: HED
###############################################################################

injunctive_model_01 <- read.csv("prepare-publication-tables/HED/injunctive_model_01.csv") %>% select(-p)
injunctive_model_02 <- read.csv("prepare-publication-tables/HED/injunctive_model_02.csv") %>% select(-p)
injunctive_model_03 <- read.csv("prepare-publication-tables/HED/injunctive_model_03.csv") %>% select(-p)
injunctive_model_05 <- read.csv("prepare-publication-tables/HED/injunctive_model_04.csv") %>% select(-p)
injunctive_model_07 <- read.csv("prepare-publication-tables/HED/injunctive_model_05.csv") %>% select(-p)


all_models <- full_join(x = injunctive_model_01, y = injunctive_model_02, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_03, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_05, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_07, by = "parameter")

colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=5))

print(all_models)
write.csv(all_models, "prepare-publication-tables/HED/injunctive_HED.csv", na = "")

injunctive_model_04 <- read.csv("prepare-publication-tables/DASS/baseline_HED_model_06.csv") %>% select(-p)
injunctive_model_06 <- read.csv("prepare-publication-tables/DASS/baseline_HED_model_07.csv") %>% select(-p)
all_models <- full_join(x = injunctive_model_04, y = injunctive_model_06, by = "parameter")
colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=2))

print(all_models)
write.csv(all_models, "prepare-publication-tables/DASS/baseline_HED.csv", na = "")

###############################################################################
# Tables for the mediated effects: RAPI
###############################################################################

qualitative <- read.csv("prepare-publication-tables/RAPI/injunctive_qualitative_role_overload_mediated_effect_model_02_and_model_06.csv")
quantitative <- read.csv("prepare-publication-tables/RAPI/injunctive_quantitative_role_overload_mediated_effect_model_02_and_model_06.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/RAPI/merged_injunctive_mediated_effect_model_02_and_model_06.csv", na = "")

qualitative <- read.csv("prepare-publication-tables/RAPI/injunctive_qualitative_role_overload_mediated_effect_model_03_and_model_06.csv")
quantitative <- read.csv("prepare-publication-tables/RAPI/injunctive_quantitative_role_overload_mediated_effect_model_03_and_model_06.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/RAPI/merged_injunctive_mediated_effect_model_03_and_model_06.csv", na = "")

qualitative <- read.csv("prepare-publication-tables/RAPI/injunctive_qualitative_role_overload_mediated_effect_model_05_and_model_07.csv")
quantitative <- read.csv("prepare-publication-tables/RAPI/injunctive_quantitative_role_overload_mediated_effect_model_05_and_model_07.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/RAPI/merged_injunctive_mediated_effect_model_05_and_model_07.csv", na = "")

###############################################################################
# Tables for the mediated effects: HED
###############################################################################

qualitative <- read.csv("prepare-publication-tables/HED/injunctive_qualitative_role_overload_mediated_effect_model_02_and_model_06.csv")
quantitative <- read.csv("prepare-publication-tables/HED/injunctive_quantitative_role_overload_mediated_effect_model_02_and_model_06.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/HED/merged_injunctive_mediated_effect_model_02_and_model_06.csv", na = "")

qualitative <- read.csv("prepare-publication-tables/HED/injunctive_qualitative_role_overload_mediated_effect_model_03_and_model_06.csv")
quantitative <- read.csv("prepare-publication-tables/HED/injunctive_quantitative_role_overload_mediated_effect_model_03_and_model_06.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/HED/merged_injunctive_mediated_effect_model_03_and_model_06.csv", na = "")

qualitative <- read.csv("prepare-publication-tables/HED/injunctive_qualitative_role_overload_mediated_effect_model_05_and_model_07.csv")
quantitative <- read.csv("prepare-publication-tables/HED/injunctive_quantitative_role_overload_mediated_effect_model_05_and_model_07.csv")
combined <- cbind(qualitative, quantitative[,-1])
write.csv(combined, "prepare-publication-tables/HED/merged_injunctive_mediated_effect_model_05_and_model_07.csv", na = "")





