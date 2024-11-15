# grouped make rule to create all three grain CSV files and opportunity exclusion
.PHONY: final_sheets
final_sheets: Final_Output/wheat_${YEAR} Final_Output/maize_${YEAR} Final_Output/rice_${YEAR} Final_Output/opportunity_exclusion_${YEAR}

# make rules for opportunity exclusion
Final_Output/opportunity_exclusion_${YEAR}: Code/opportunity_exclusion.R Final_Output/wheat_${YEAR} Final_Output/maize_${YEAR} Final_Output/rice_${YEAR} Raw_Data/country_names.csv Raw_Data/percent_ip_urban_${YEAR}.csv
	Rscript Code/opportunity_exclusion.R

# make rules for annual report combined FAO and non-FAO grain sheets 
Final_Output/wheat_${YEAR}: Code/wheat.R Cleaned_Data/fao_sua_${YEAR}.rds Cleaned_Data/fao_foodbalance_${YEAR}.rds Cleaned_Data/nonfao_wheat_${YEAR}.rds Raw_Data/country_names.csv
	Rscript Code/wheat.R

Final_Output/maize_${YEAR}: Code/maize.R Cleaned_Data/fao_sua_${YEAR}.rds Cleaned_Data/fao_foodbalance_${YEAR}.rds Cleaned_Data/nonfao_maize_${YEAR}.rds Raw_Data/country_names.csv
	Rscript Code/maize.R

Final_Output/rice_${YEAR}: Code/rice.R Cleaned_Data/fao_sua_${YEAR}.rds Cleaned_Data/fao_foodbalance_${YEAR}.rds Raw_Data/nonfao_rice_${YEAR}.csv Raw_Data/country_names.csv
	Rscript Code/rice.R

# make rules for cleaned data
Cleaned_Data/fao_foodbalance_${YEAR}.rds: Code/clean_fao_data.R Raw_Data/fao_foodbalance_${YEAR}.csv
	Rscript Code/clean_fao_data.R
	
Cleaned_Data/fao_sua_${YEAR}.rds: Code/clean_fao_data.R Raw_Data/fao_sua_${YEAR}.csv 
	Rscript Code/clean_fao_data.R
	
Cleaned_Data/nonfao_wheat_${YEAR}.rds: Code/clean_nonfao_data.R Raw_Data/nonfao_wheat_${YEAR}.csv
	Rscript Code/clean_nonfao_data.R
	
Cleaned_Data/nonfao_maize_${YEAR}.rds: Code/clean_nonfao_data.R Raw_Data/nonfao_maize_${YEAR}.csv 
	Rscript Code/clean_nonfao_data.R
	
# make clean rule
clean:
	rm Cleaned_Data/*.rds && rm Final_Output/*.csv