library(readxl)
library(dplyr)

path.wnw.data <- Sys.getenv("path.wnw.data")
path.baseline.data <- Sys.getenv("path.baseline.data")
path.screener.data <- Sys.getenv("path.screener.data")

wnwdata <- read_xlsx(file.path(path.wnw.data, "C2W - Working Not Working - Alldata.xlsx"), sheet = "alldata")
baselinedata <- read_xlsx(file.path(path.baseline.data, "C2W- Baseline - Alldata.xlsx"), sheet = "Alldata")
screenerdata <- read_xlsx(file.path(path.screener.data, "C2W - Screener - Alldata.xlsx"), sheet = "alldata")

df.summary <- wnwdata %>% 
  filter(wnw1==1 | wnw1==3 | wnw1==5) %>% 
  group_by(ParticipantID) %>% 
  summarise(first.month.fulltime = min(survey_timepoint))

df.summary$post.twelve.months <- df.summary$first.month.fulltime + 12
wnwdata <- left_join(x = wnwdata, y = df.summary, by = "ParticipantID")

wnwdata <- wnwdata %>% select(ParticipantID, first.month.fulltime, post.twelve.months, everything())
df.summary.appended <- wnwdata %>% 
  select(ParticipantID, survey_timepoint, first.month.fulltime, post.twelve.months, wnw1) %>%
  filter(survey_timepoint==first.month.fulltime | survey_timepoint==post.twelve.months) %>%
  mutate(timevar = if_else(survey_timepoint==first.month.fulltime, 0, 1))

df.time <- df.summary.appended %>% select(id = ParticipantID, first.month.fulltime, post.twelve.months, time = timevar, wnw1)
df.time.0 <- df.time %>% filter(time==0) %>% select(id, first.month.fulltime, post.twelve.months)
df.time.1 <- df.time %>% filter(time==1) %>% filter(wnw1==1 | wnw1==3 | wnw1==5) %>% select(id, wnw1)
df.time.0 <- left_join(x=df.time.0, y=df.time.1, by="id")
df.time.0 <- df.time.0 %>% filter(!is.na(wnw1))

