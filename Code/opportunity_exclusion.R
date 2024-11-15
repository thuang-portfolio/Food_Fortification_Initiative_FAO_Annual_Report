# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/opportunity_exclusion.R")

# get year parameter
config_list <- config::get()

# read in data and country names
file_name_1 <- paste0("Final_Output/wheat_", config_list$year, ".csv")
wheat <- read.csv(file = here::here(file_name_1), header = TRUE)

file_name_2 <- paste0("Final_Output/maize_", config_list$year, ".csv")
maize <- read.csv(file = here::here(file_name_2), header = TRUE)

file_name_3 <- paste0("Final_Output/rice_", config_list$year, ".csv")
rice <- read.csv(file = here::here(file_name_3), header = TRUE)

file_name_4 <- paste0("Raw_Data/percent_ip_urban_", config_list$year, ".csv")
percent_ip_urban <- read.csv(file = here::here(file_name_4), header = TRUE)
  
wheat_percent_ip <- percent_ip_urban$wheat_percent_ip
maize_percent_ip <- percent_ip_urban$maize_percent_ip
rice_percent_ip <- percent_ip_urban$rice_percent_ip
percent_urban <- percent_ip_urban$percent_urban

# create secondary dataframe 
op <- data.frame(percent_ip_urban$country_name, wheat$wheat_intake, maize$maize_intake,
                 rice$rice_intake, wheat_percent_ip, maize_percent_ip, rice_percent_ip, 
                 percent_urban) %>% 
      rename(country_name = percent_ip_urban.country_name,
             wheat_intake = wheat.wheat_intake, 
             maize_intake = maize.maize_intake, 
             rice_intake = rice.rice_intake)

# apply first exclusion rule: For wheat, exclude any country that consumes less than 25 g/c/d. 
# For maize and rice, exclude any country that consumes less than 37.5 g/c/d 
op <- op %>% mutate(wheat_op = ifelse(wheat_intake < 25, "", wheat_intake)) %>% 
  mutate(maize_op = ifelse(maize_intake < 37.5, "", maize_intake)) %>% 
  mutate(rice_op = ifelse(rice_intake < 37.5, "", rice_intake)) 

op[,2:11] <- sapply(op[,2:11], as.numeric) 

# apply second exclusion rule: Exclude any grain which is consumed 3x (or more) less than the most consumed grain 
# include any grain that is consumed 3x more than the most consumed grain

# abbreviations: first grain is the most consumed, second grain is the less consumed grain
# NOTE: 1 in the columns means the second grain should be excluded

op <- op %>% mutate(wheat_maize = ifelse(wheat_op > (maize_op*3), 1, 0)) %>%  # if wheat is most consumed grain 
  mutate(wheat_rice = ifelse(wheat_op > (rice_op*3), 1, 0)) %>% # if wheat is most consumed grain
  mutate(maize_wheat = ifelse(maize_op > (wheat_op*3), 1, 0)) %>% # if maize is most consumed grain
  mutate(maize_rice = ifelse(maize_op > (rice_op*3), 1, 0)) %>% # if maize is most consumed grain
  mutate(rice_wheat = ifelse(rice_op > (wheat_op*3), 1, 0)) %>% # if rice is most consumed grain
  mutate(rice_maize = ifelse(rice_op > (maize_op*3), 1, 0)) # if rice is most consumed grain

op[is.na(op)] <- 0

# apply exception to second exclusion rule: if a country has higher than 35% urbanicity, and the lesser consumed grain has the same or higher percent 
# industrially processed (%IP) than the most consumed grain, it can be left in as an opportunity for fortification. 

# if rice is the less consumed grain
op$rice_op <-  ifelse(op$wheat_rice == 1 & op$percent_urban < 35 | op$wheat_rice ==1 & op$percent_urban >= 35 & op$rice_percent_ip < op$wheat_percent_ip, "", op$rice_op) 
op$rice_op <-  ifelse(op$maize_rice == 1 & op$percent_urban < 35 | op$maize_rice ==1 & op$percent_urban >= 35 & op$rice_percent_ip < op$maize_percent_ip, "", op$rice_op)

# if maize is the less consumed grain
op$maize_op <- ifelse(op$wheat_maize == 1 & op$percent_urban < 35 | op$wheat_maize ==1 & op$percent_urban >= 35 & op$maize_percent_ip < op$wheat_percent_ip, "", op$maize_op)
op$maize_op <- ifelse(op$rice_maize == 1 & op$percent_urban < 35 | op$rice_maize ==1 & op$percent_urban >= 35 & op$maize_percent_ip < op$rice_percent_ip, "", op$maize_op)

# if wheat is the less consumed grain
op$wheat_op <- ifelse(op$rice_wheat == 1 & op$percent_urban < 35 | op$rice_wheat ==1 & op$percent_urban >= 35 & op$wheat_percent_ip < op$rice_percent_ip, "", op$wheat_op)
op$wheat_op <- ifelse(op$maize_wheat == 1 & op$percent_urban < 35 | op$maize_wheat ==1 & op$percent_urban >= 35 & op$wheat_percent_ip < op$maize_percent_ip, "", op$wheat_op)

op <- op %>%  mutate(wheat_opportunity = ifelse(wheat_op > 0, 1, 0)) %>% 
  mutate(maize_opportunity = ifelse(maize_op > 0, 1, 0)) %>% 
  mutate(rice_opportunity = ifelse(rice_op > 0, 1, 0))

op <- op %>%  select(country_name, wheat_opportunity, maize_opportunity, rice_opportunity)

# export CSV
file_name_5 <- paste0("Final_Output/opportunity_exclusion_", config_list$year, ".csv")
write.csv(op, 
          file = here::here(file_name_5))