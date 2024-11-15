# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/clean_fao_data.R")

# get year parameter
config_list <- config::get()

# read in raw FAO SUA and FB data
file_name_1 <- paste0("Raw_Data/fao_sua_", config_list$year, ".csv")
fao_sua_data <- read.csv(here::here(file_name_1), header = TRUE)

file_name_2 <- paste0("Raw_Data/fao_foodbalance_", config_list$year, ".csv")
fao_fb_data <- read.csv(here::here(file_name_2), header = TRUE)

# Recode country names for both FAO datasets
fao_sua_data <- fao_sua_data %>% mutate(Area = recode(Area, 
                                                      "Bolivia (Plurinational State of)"="Bolivia, Plurinational State of", 
                                                      "China" = "China, People's Republic of",
                                                      "Czechia" = "Czech Republic",
                                                      "Côte d'Ivoire" = "Cote d'Ivoire",
                                                      "Democratic People's Republic of Korea" = "Korea, Democratic People's Republic of",
                                                      "Eswatini" = "Eswatini, the Kingdom of",
                                                      "Gambia" = "Gambia, Republic of The",
                                                     # "Guinea-Bissau" = "GuineaBissau",
                                                      "Iran (Islamic Republic of)" = "Iran, Islamic Republic of",
                                                      "Micronesia (Federated States of)" = "Micronesia, Federated States of",
                                                      "Netherlands (Kingdom of the)" = "Netherlands",
                                                      "North Macedonia" = "Macedonia, The former Yugoslav Republic of",
                                                      "Republic of Korea"= "Korea, Republic of",
                                                      "Republic of Moldova" = "Moldova, Republic of", 
                                                      #"Timor-Leste" = "TimorLeste",
                                                      #"Türkiye" = "Turkey", 
                                                      # "United Kingdom of Great Britain and Northern Ireland" = "United Kingdom",
                                                      "United Republic of Tanzania" = "Tanzania, United Republic of",
                                                      "Venezuela (Bolivarian Republic of)" = "Venezuela, Bolivarian Republic of"))  

fao_fb_data <- fao_fb_data %>% mutate(Area = recode(Area, 
                                                    "Bolivia (Plurinational State of)"="Bolivia, Plurinational State of", 
                                                    "China" = "China, People's Republic of",
                                                    "Czechia" = "Czech Republic",
                                                    "Côte d'Ivoire" = "Cote d'Ivoire",
                                                    "Democratic People's Republic of Korea" = "Korea, Democratic People's Republic of",
                                                    "Eswatini" = "Eswatini, the Kingdom of",
                                                    "Gambia" = "Gambia, Republic of The",
                                                    # "Guinea-Bissau" = "GuineaBissau",
                                                    "Iran (Islamic Republic of)" = "Iran, Islamic Republic of",
                                                    "Micronesia (Federated States of)" = "Micronesia, Federated States of",
                                                    "Netherlands (Kingdom of the)" = "Netherlands",
                                                    "North Macedonia" = "Macedonia, The former Yugoslav Republic of",
                                                    "Republic of Korea"= "Korea, Republic of",
                                                    "Republic of Moldova" = "Moldova, Republic of", 
                                                    #"Timor-Leste" = "TimorLeste",
                                                    #"Türkiye" = "Turkey", 
                                                    # "United Kingdom of Great Britain and Northern Ireland" = "United Kingdom",
                                                    "United Republic of Tanzania" = "Tanzania, United Republic of",
                                                    "Venezuela (Bolivarian Republic of)" = "Venezuela, Bolivarian Republic of"))

# export cleaned datasets
file_name_3 <- paste0("Cleaned_Data/fao_sua_", config_list$year, ".rds")
saveRDS(
  fao_sua_data, 
  file = here::here(file_name_3)
)

file_name_4 <- paste0("Cleaned_Data/fao_foodbalance_", config_list$year, ".rds")
saveRDS(
  fao_fb_data, 
  file = here::here(file_name_4)
)
