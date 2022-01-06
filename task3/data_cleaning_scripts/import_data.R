# Import Libraries
  
library(tidyverse)
library(janitor)
library(readxl)
library(here)


# Excel Spreadsheet Import
## Look at the sheets

# Identify the sheets in the spreadsheet
excel_sheets(here("raw_data/seabirds.xls"))

## Import required sheets

ship_data <- 
  read_excel(here("raw_data/seabirds.xls"), 
             sheet = 1)

bird_data <- 
  read_excel(here("raw_data/seabirds.xls"), 
             sheet = 2)

## Rename columns
colnames(bird_data)[3]  <- "species"
colnames(bird_data)[4]  <- "scientific_name"
colnames(bird_data)[5]  <- "abbreviation"


## Create one table

# Create one table using left_join
full_data <- left_join(bird_data, ship_data, by = "RECORD ID")

## Export to csv file

write_csv(full_data, here("clean_data/full_data.csv"))


