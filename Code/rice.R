# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/rice.R")

# get year parameter
config_list <- config::get()

# read in FAO SUA data, FAO FB data, nonfao rice data, and country names
file_name_1 <- paste0("Cleaned_Data/fao_sua_", config_list$year, ".rds")
fao_sua_data <- readRDS(file = here::here(file_name_1))

file_name_2 <- paste0("Cleaned_Data/fao_foodbalance_", config_list$year, ".rds")
fao_fb_data <- readRDS(file = here::here(file_name_2))

file_name_3 <- paste0("Raw_Data/nonfao_rice_", config_list$year, ".csv")
nonfao_rice <- read.csv(file = here::here(file_name_3), header = TRUE)

country_names <- read.csv(here::here("Raw_Data/country_names.csv"), header = TRUE)

# Intake - g/c/d
rice_intake_data <- fao_sua_data %>%  
  filter(Element == "Food supply quantity (g/capita/day)",
         Item %in% c("Rice, broken", "Rice, milled", "Husked rice")) %>%
  group_by(Area) %>%
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, rice_intake = Total) %>% 
  mutate(source_rice_intake = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                     config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Supply (MT)
rice_supply_data <- fao_sua_data %>%  
  filter(Element == "Food supply quantity (tonnes)",
         Item %in% c("Rice, broken", "Rice, milled", "Husked rice")) %>%
  group_by(Area) %>% 
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, rice_supply = Total) %>%
  mutate(source_rice_supply = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                     config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Grain Production 
rice_prod_data <- fao_sua_data %>%  
  filter(Element == "Production",
         Item %in% c("Rice, broken", "Rice, milled", "Husked rice")) %>%
  group_by(Area) %>% 
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, rice_prod = Total) %>%
  mutate(source_rice_prod = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                   config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Grain Imports 
rice_grain_imports_data <- fao_sua_data %>%  
  filter(Element == "Import Quantity",
         Item %in% c("Rice, broken", "Rice, milled", "Husked rice")) %>%
  group_by(Area) %>% 
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, rice_grain_imports = Total) %>%
  mutate(source_rice_grain_imports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                     config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Grain Exports  
rice_grain_exports_data <- fao_sua_data %>%  
  filter(Element == "Export Quantity",
         Item %in% c("Rice, broken", "Rice, milled", "Husked rice")) %>%
  group_by(Area) %>% 
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, rice_grain_exports = Total) %>%
  mutate(source_rice_grain_exports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                     config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Join and coalesce 
rice_sheet <- list(country_names, rice_supply_data, rice_prod_data,
                   rice_grain_imports_data, rice_grain_exports_data, 
                   rice_intake_data) %>% 
  reduce(left_join, by = "country_name")

# add non-FAO data
rice_final <- rice_sheet %>% rows_patch(nonfao_rice, by = "country_name") 

# turn NA's into blanks
rice_final[is.na(rice_final)] <- " "

# export 
file_name_4 <- paste0("Final_Output/rice_", config_list$year, ".csv")
write.csv(rice_final, 
          file = here::here(file_name_4),
          row.names = FALSE)