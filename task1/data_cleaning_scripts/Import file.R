library(tidyverse)
library(here)
library(tibble)

# cleaning variables
decathlon <- janitor::clean_names(read_rds(here("raw_data/decathlon.rds")))

# creating name column for row names and standardising names
decathlon <- decathlon %>% 
  tibble::rownames_to_column("name") %>%
  mutate(name = str_to_title(name))

# creating rds file of cleaned data
write_rds(decathlon, "clean_data/clean_decathlon.rds")
