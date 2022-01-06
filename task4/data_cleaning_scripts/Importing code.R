# Setup packages ----

library (tidyverse)
library (readxl)
library (janitor)
library (here)

# Import the Excel Data ----

rawdata_2015 <- read_excel(here("raw_data/boing-boing-candy-2015.xlsx")) %>% 
  clean_names()
rawdata_2016 <- read_excel(here("raw_data/boing-boing-candy-2016.xlsx")) %>% 
  clean_names()
rawdata_2017 <- read_excel(here("raw_data/boing-boing-candy-2017.xlsx")) %>% 
  clean_names()

# This strips out the q6_ from the beginning of the column names
names(rawdata_2017) = gsub(pattern = "^q[0-9]_", replacement = "", 
                           x = names(rawdata_2017))

# Remove unwanted columns
cut_2015 <- rawdata_2015 %>% select(2:96)
cut_2016 <- rawdata_2016 %>% select(2:106)
cut_2017 <- rawdata_2017 %>% select(2:109)

# Rename columns 2015
candy_2015 <-
  cut_2015 %>% 
  rename(
    age = how_old_are_you,
    going_out = are_you_going_actually_going_trick_or_treating_yourself,
    bonkers_the_candy = bonkers,
    boxo_raisins = box_o_raisins,
    hersheys_dark_chocolate = dark_chocolate_hershey,
    hersheys_kisses = hershey_s_kissables,
    licorice_yes_black = licorice,
    sweetums_a_friend_to_diabetes = sweetums
  )

# Rename columns 2016
candy_2016 <-
  cut_2016 %>% 
  rename(
    age = how_old_are_you,
    going_out = are_you_going_actually_going_trick_or_treating_yourself,
    gender = your_gender,
    country = which_country_do_you_live_in,
    state_province_county_etc = which_state_province_county_do_you_live_in
  )

# Rename columns 2017
candy_2017 <-
  cut_2017 %>% 
  rename(
    anonymous_brown_globs_that_come_in_black_and_orange_wrappers = 
      anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes
  )

# Compare dataset columns
comparison <- compare_df_cols(candy_2017, candy_2016, candy_2015)

# Add in a column for the year and move that to the front
candy_2017['year']=2017
candy_2017 <- candy_2017[, c(109,1:108)]
candy_2016['year']=2016
candy_2016 <- candy_2016[, c(106,1:105)]
candy_2015['year']=2015
candy_2015 <- candy_2015[, c(96,1:95)]

# Combine all three data sets into one
combined <- bind_rows(candy_2017, candy_2016, candy_2015)

# Clean the age column
# Change the data type to integer
combined$age <- as.integer(combined$age)

combined <- combined %>% 
  mutate(age = ifelse(age <= 100, age, NA_integer_))

# Create USA pattern
usa_pattern <- c("usausausa|usas|usaa|usa? hard to tell anymore..|usa!!!!!!
                 |usa! usa!|usa!|usa usa usa!!!!|usa usa usa usa|usausausa
                 |usas|usaa|usa? hard to tell anymore..|usa!!!!!!|usa! usa!
                 |usa!|usa usa usa!!!!|usa usa usa usa|usa usa usa|usa|usa
                 |units states|united ststes|united      ststes|usa|us|usa
                 |united states of america|us|united states|united states
                 |u.s.a.|united states of america|america|america|u.s.
                 |murica|unites states|us of a|united state|usa! usa! usa!
                 |merica|the united states|united sates|united stated|ussa
                 |ahem....amerca|n. america|the best one - usa
                 |the united states of america|	the yoo ess of aaayyyyyy|u s
                 |u s a|u.s.|u.s.a.|unied states|unhinged states|unied states
                 |unite states|united  states of america|united staes
                 |united statea|united states|united states
                 |united statss|united stetes|	united ststes|united ststes
                 |units states|usa|usa usa usa|usa usa usa usa|usa usa usa!!!!
                 |usa!|usa! usa!|usa!!!!!!|usa? hard to tell anymore..|usaa
                 |usas|usausausa|trumpistan|alaska
                 |i pretend to be from canada, but i am really from the usa.
                 |fear and loathing|united ststes|usa of a|usa of usa|usa usa
                 |usaa|usaa|usaa? hard to tell anymore..|usaa.|usaa.|usad|usasa
                 |new york|new jersey|murrika|the yoo ess of aaayyyyyy")

uk_pattern <- c("endland|england|united kindom|united kingdom|uk|u.k.|scotland")

# In the combined table 
#   change the country code to lower case
#   using the patterns replace the uk and usa fields

combined<- combined %>%
  mutate(country = str_to_lower(country)) 

combined <- combined %>% 
  mutate(country = case_when(
    str_detect(country, "not[\\s]{1,}") ~ NA_character_,
    str_detect(country, "australia") ~ "other",
    str_detect(country, "soviet canuckistan") ~ "other",   
    str_detect(country, "austria") ~ "other",
    str_detect(country, str_c(usa_pattern, collapse = "|")) ~ "usa",
    str_detect(country, str_c(uk_pattern, collapse = "|")) ~ "uk",
    str_detect(country, "^can") ~ "canada",
    is.na(country) == TRUE ~ NA_character_,
    TRUE ~ "other")
  )

## Export to csv file
write_csv(combined, here("clean_data/candy_data.csv"))
