# load packages
pacman::p_load(tidyverse, here)

# specify file location relative to project folder
here::i_am("Code/wheat.R")

# get year parameter
config_list <- config::get()

# read in FAO SUA data, FAO FB data, nonfao wheat data, and country names
file_name_1 <- paste0("Cleaned_Data/fao_sua_", config_list$year, ".rds")
fao_sua_data <- readRDS(file = here::here(file_name_1))

file_name_2 <- paste0("Cleaned_Data/fao_foodbalance_", config_list$year, ".rds")
fao_fb_data <- readRDS(file = here::here(file_name_2))

file_name_3 <- paste0("Cleaned_Data/nonfao_wheat_", config_list$year, ".rds")
nonfao_wheat <- readRDS(file = here::here(file_name_3))

country_names <- read.csv(here::here("Raw_Data/country_names.csv"), header = TRUE)

# Intake - g/c/d
wheat_intake_data <- fao_sua_data %>% 
  filter(Element == "Food supply quantity (g/capita/day)", Item == "Wheat and meslin flour") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, wheat_intake = Value) %>%
  mutate(source_wheat_intake = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Supply (MT)
wheat_supply_data <- fao_sua_data %>%  
  filter(Element == "Food supply quantity (tonnes)", 
         Item %in% c("Bread","Bulgur","Pastry", "Wheat",
                     "Uncooked pasta, not stuffed or otherwise prepared",
                     "Wheat and meslin flour")) %>%
  group_by(Area) %>% 
  mutate(Total=sum(Value)) %>% 
  select(Area, Total) %>% 
  distinct(Area, .keep_all = TRUE) %>% 
  rename(country_name = Area, wheat_supply = Total) %>%
  mutate(source_wheat_supply = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Flour Imports 
wheat_flour_imports_data <- fao_sua_data %>%  
  filter(Element == "Import Quantity", Item == "Wheat and meslin flour") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, wheat_flour_imports = Value) %>%
  mutate(source_wheat_flour_imports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Flour Exports 
wheat_flour_exports_data <- fao_sua_data %>%  
  filter(Element == "Export Quantity", Item == "Wheat and meslin flour") %>%
  select(Area, Value) %>% 
  rename(country_name = Area, wheat_flour_exports = Value) %>%
  mutate(source_wheat_flour_exports = paste0("FAO. Supply Utilization Accounts. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/SCL]."))

# Grain Production 
wheat_prod_data <- fao_fb_data %>%  
  filter(Element == "Production", Item == "Wheat and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, wheat_prod = Value) %>%
  mutate(wheat_prod = wheat_prod*1000) %>%
  mutate(source_wheat_prod = paste0("FAO. New Food Balances. Italy. ", 
                                    config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Grain Imports 
wheat_grain_imports_data <- fao_fb_data %>%  
  filter(Element == "Import Quantity", Item == "Wheat and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, wheat_grain_imports = Value) %>%
  mutate(wheat_grain_imports = wheat_grain_imports*1000) %>%
  mutate(source_wheat_grain_imports = paste0("FAO. New Food Balances. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Grain Exports 
wheat_grain_exports_data <- fao_fb_data %>%  
  filter(Element == "Export Quantity", Item == "Wheat and products") %>%
  select(Area, Value) %>%
  rename(country_name = Area, wheat_grain_exports = Value) %>%
  mutate(wheat_grain_exports = wheat_grain_exports*1000) %>%
  mutate(source_wheat_grain_exports = paste0("FAO. New Food Balances. Italy. ", 
                                      config_list$source_year, ". [https://www.fao.org/faostat/en/#data/FBS]."))

# Join items
wheat_sheet <- list(country_names, wheat_supply_data, wheat_prod_data,
                    wheat_grain_imports_data, wheat_grain_exports_data,
                    wheat_flour_imports_data, wheat_flour_exports_data,
                    wheat_intake_data) %>% 
  reduce(left_join, by = "country_name")

# add non-FAO data
wheat_final <- wheat_sheet %>% rows_patch(nonfao_wheat, by = "country_name") 

# turn NA's into blanks
wheat_final[is.na(wheat_final)] <- " "

#export 
file_name_4 <- paste0("Final_Output/wheat_", config_list$year, ".csv")
write.csv(wheat_final, 
          file = here::here(file_name_4),
          row.names = FALSE)