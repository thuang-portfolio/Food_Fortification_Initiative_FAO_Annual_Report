# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/maize.R")

# get year parameter
config_list <- config::get()

# read in FAO SUA data, FAO FB data, nonfao maize data, and country names
file_name_1 <- paste0("Cleaned_Data/fao_sua_", config_list$year, ".rds")
fao_sua_data <- readRDS(file = here::here(file_name_1))

file_name_2 <- paste0("Cleaned_Data/fao_foodbalance_", config_list$year, ".rds")
fao_fb_data <- readRDS(file = here::here(file_name_2))

file_name_3 <- paste0("Cleaned_Data/nonfao_maize_", config_list$year, ".rds")
nonfao_maize <- readRDS(file = here::here(file_name_3))

country_names <- read.csv(here::here("Raw_Data/country_names.csv"), header = TRUE)

# Intake - g/c/d
maize_intake_data <- fao_sua_data %>% 
  filter(Element == "Food supply quantity (g/capita/day)", Item == "Flour of maize") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, maize_intake = Value) %>%
  mutate(source_maize_intake = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Supply (MT)
maize_supply_data <- fao_sua_data %>%  
  filter(Element == "Food supply quantity (tonnes)", 
         Item == "Flour of maize") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, maize_supply = Value) %>%
  mutate(source_maize_supply = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Flour Imports 
maize_flour_imports_data <- fao_sua_data %>%  
  filter(Element == "Import Quantity", Item == "Flour of maize") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, maize_flour_imports = Value) %>%
  mutate(source_maize_flour_imports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                             config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Flour Exports 
maize_flour_exports_data <- fao_sua_data %>%  
  filter(Element == "Export Quantity", Item == "Flour of maize") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, maize_flour_exports = Value) %>%
  mutate(source_maize_flour_exports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                             config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Grain Production 
maize_prod_data <- fao_fb_data %>%  
  filter(Element == "Production", Item == "Maize and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, maize_prod = Value) %>%
  mutate(maize_prod = maize_prod*1000) %>%
  mutate(source_maize_prod = paste0("FAO. New Food Balances. Italy. ", 
                                    config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Grain Imports 
maize_grain_imports_data <- fao_fb_data %>%  
  filter(Element == "Import Quantity", Item == "Maize and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, maize_grain_imports = Value) %>%
  mutate(maize_grain_imports = maize_grain_imports*1000) %>%
  mutate(source_maize_grain_imports = paste0("FAO. New Food Balances. Italy. ", 
                                             config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Grain Exports 
maize_grain_exports_data <- fao_fb_data %>%  
  filter(Element == "Export Quantity", Item == "Maize and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, maize_grain_exports = Value) %>%
  mutate(maize_grain_exports = maize_grain_exports*1000) %>%
  mutate(source_maize_grain_exports = paste0("FAO. New Food Balances. Italy. ", 
                                             config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Join items
maize_sheet <- list(country_names, maize_supply_data, maize_prod_data,
                    maize_grain_imports_data, maize_grain_exports_data,
                    maize_flour_imports_data, maize_flour_exports_data,
                    maize_intake_data) %>% 
  reduce(left_join, by = "country_name")

# add non-FAO data
maize_final <- maize_sheet %>% rows_patch(nonfao_maize, by = "country_name") 

# turn NA's into blanks
maize_final[is.na(maize_final)] <- " "

# export
file_name_4 <- paste0("Final_Output/maize_", config_list$year, ".csv")
write.csv(maize_final, 
          file = here::here(file_name_4),
          row.names = FALSE)