# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/clean_fao_data.R")

# get year parameter
config_list <- config::get()

# read in raw non-FAO data
file_name_1 <- paste0("Raw_Data/nonfao_wheat_", config_list$year, ".csv")
nonfao_wheat_data <- read.csv(here::here(file_name_1), header = TRUE)

file_name_2 <- paste0("Raw_Data/nonfao_maize_", config_list$year, ".csv")
nonfao_maize_data <- read.csv(here::here(file_name_2), header = TRUE)

# remove wheat flour product columns 
wheat_drop <- c("wheat_flour_products_imports","source_wheat_flour_products_imports",
                 "wheat_flour_products_exports", "source_wheat_flour_products_exports")
nonfao_wheat_data <- nonfao_wheat_data[ , !(names(nonfao_wheat_data) %in% wheat_drop)]

# remove maize flour product columns 
maize_drop <- c("maize_flour_products_imports","source_maize_flour_products_imports",
                "maize_flour_products_exports", "source_maize_flour_products_exports")
nonfao_maize_data <- nonfao_maize_data[ , !(names(nonfao_maize_data) %in% maize_drop)]

# export cleaned datasets
file_name_3 <- paste0("Cleaned_Data/nonfao_wheat_", config_list$year, ".rds")
saveRDS(
  nonfao_wheat_data, 
  file = here::here(file_name_3)
)

file_name_4 <- paste0("Cleaned_Data/nonfao_maize_", config_list$year, ".rds")
saveRDS(
  nonfao_maize_data, 
  file = here::here(file_name_4)
)