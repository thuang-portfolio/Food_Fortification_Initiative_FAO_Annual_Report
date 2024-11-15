# Prep

Follow the instructions in the "FFI Annual Report Data Compilation in R" SOP

# Project Directory Description

-   `Raw_Data/` folder should eventually contain the seven raw CSV files

    -   "fao_sua_YEAR.csv"
    -   "fao_foodbalance_YEAR.csv"
    -   "nonfao_wheat_YEAR.csv"
    -   "nonfao_maize_YEAR.csv"
    -   "nonfao_rice_YEAR.csv"
    -   "country_names.csv"
    -   "percent_ip_urban_YEAR.csv"

-   `Cleaned_Data/` folder should eventually contain the four cleaned RDS files

    -   "fao_sua_YEAR.rds"
    -   "fao_foodbalance_YEAR.rds"
    -   "nonfao_wheat_YEAR.rds"
    -   "nonfao_maize_YEAR.rds"

-   `Final_Output/` folder should eventually contain three final CSV files that merge FAO
    and non-FAO data for each grain

    -   "wheat_YEAR.csv"
    -   "maize_YEAR.csv"
    -   "rice_YEAR.csv"

-   `Code/` folder contains R scripts described below

-   `Makefile` is a document that specifies how to build the three final
    grain sheets automatically. Essentially, it contains rules to
    create each output so one can use a shortcut and doesn't have to run
    all of the individual R code scripts separately.

-   `config.yml` is a document that specifies a parameter or variable
    that we don't want hard-coded into any of the code since it can
    change. It contains two parameters (the year of the current annual
    report and the year of the sources) so file names can be customized to the current annual
    report's year.
  
# Code Description

-   `Code/clean_fao_data.R`:
    -   clean FAO SUA and Food Balances data from `Raw_Data/` folder
    -   save cleaned data files in `Cleaned_Data/` folder
-   `Code/clean_nonfao_data.R`:
    -   clean non-FAO data from `Raw_Data/` folder
    -   save cleaned data files in `Cleaned_Data/` folder
-   `Code/wheat.R`:
    -   read in and compile FAO and non-FAO data for wheat
    -   save wheat sheet in `Final_Output/` folder
-   `Code/maize.R`:
    -   read in and compile FAO and non-FAO data for maize
    -   save maize sheet in `Final_Output/` folder
-   `Code/rice.R`:
    -   read in and compile FAO and non-FAO data for rice
    -   save rice sheet in `Final_Output/` folder
-   `Code/opportunity_exclusion.R`:
    -   read in and compile wheat, maize, and rice sheets and calculate opportunity exclusion
    -   save opportunity exclusion sheet in `Final_Output/` folder
