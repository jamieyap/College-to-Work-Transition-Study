library(dplyr)

injunctive_model_01 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_01.csv") %>% select(-p)
injunctive_model_02 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_02.csv") %>% select(-p)
injunctive_model_03 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_03.csv") %>% select(-p)
injunctive_model_05 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_05.csv") %>% select(-p)
injunctive_model_07 <- read.csv("prepare-publication-tables/RAPI/injunctive_model_07.csv") %>% select(-p)


all_models <- full_join(x = injunctive_model_01, y = injunctive_model_02, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_03, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_05, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_07, by = "parameter")

colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=5))

print(all_models)
write.csv(all_models, "prepare-publication-tables/RAPI/injunctive_RAPI.csv", na = "")

injunctive_model_04 <- read.csv("prepare-publication-tables/DASS/injunctive_with_baseline_RAPI_model_04.csv") %>% select(-p)
injunctive_model_06 <- read.csv("prepare-publication-tables/DASS/injunctive_with_baseline_RAPI_model_06.csv") %>% select(-p)
all_models <- full_join(x = injunctive_model_04, y = injunctive_model_06, by = "parameter")
colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=2))

print(all_models)
write.csv(all_models, "prepare-publication-tables/DASS/injunctive_with_baseline_RAPI.csv", na = "")



injunctive_model_01 <- read.csv("prepare-publication-tables/HED/injunctive_model_01.csv") %>% select(-p)
injunctive_model_02 <- read.csv("prepare-publication-tables/HED/injunctive_model_02.csv") %>% select(-p)
injunctive_model_03 <- read.csv("prepare-publication-tables/HED/injunctive_model_03.csv") %>% select(-p)
injunctive_model_05 <- read.csv("prepare-publication-tables/HED/injunctive_model_05.csv") %>% select(-p)
injunctive_model_07 <- read.csv("prepare-publication-tables/HED/injunctive_model_07.csv") %>% select(-p)


all_models <- full_join(x = injunctive_model_01, y = injunctive_model_02, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_03, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_05, by = "parameter")
all_models <- full_join(x = all_models, y = injunctive_model_07, by = "parameter")

colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=5))

print(all_models)
write.csv(all_models, "prepare-publication-tables/HED/injunctive_HED.csv", na = "")

injunctive_model_04 <- read.csv("prepare-publication-tables/DASS/injunctive_with_baseline_HED_model_04.csv") %>% select(-p)
injunctive_model_06 <- read.csv("prepare-publication-tables/DASS/injunctive_with_baseline_HED_model_06.csv") %>% select(-p)
all_models <- full_join(x = injunctive_model_04, y = injunctive_model_06, by = "parameter")
colnames(all_models) <- c("Parameter", rep(c("Estimate","SE"), times=2))

print(all_models)
write.csv(all_models, "prepare-publication-tables/DASS/injunctive_with_baseline_HED.csv", na = "")

