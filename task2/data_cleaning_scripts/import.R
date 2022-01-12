
library(tidyverse)
library(here)
library(janitor)
library(tidyr)

here()
cake_ingredient_code <- read_csv(here("task_2/raw_data/cake/cake_ingredient_code.csv")) %>% clean_names()
cake_ingredient_1961 <- read_csv(here("task_2/raw_data/cake/cake-ingredients-1961.csv")) %>% clean_names()

head(cake_ingredient_1961) #here I can see that BM column is lgl not dbl like the rest. I need to change this so they are all numerical. This is because
# that is the only column all NA.
head(cake_ingredient_code)
tail(cake_ingredient_1961)
tail(cake_ingredient_code)
glimpse(cake_ingredient_1961)
glimpse(cake_ingredient_code)
colnames(cake_ingredient_1961)
colnames(cake_ingredient_code)
class(cake_ingredient_code)


cake_ingredient_code_lower <- cake_ingredient_code %>%
  mutate(code = tolower(code)) 
# I realised towards the end that when I clean the variable names and they become lower_case with tolower

#there are a lot of NAs in this dataset so I am not going to drop any as we would lose a lot of data. But I also dont think this is a mistake because
#each cake has different ingredients so it is not a problem if data 
#is not measured but I will replace them with 0# #I have later on realised this is a problem and returned them back to NA. further explanation later#

#I am now going to pivot the table so that the columns become code and I can join the tables with 'code'
cake_ingredient_1961_new <- cake_ingredient_1961 %>%
  pivot_longer(cols = "ae":"zh",
               names_to = "code",
               values_to = "units") 


#there is one NA in this which is the sour_cream cup measure. This I assume is missing data and will not turn to 0 because it is also character data#
#I am going to join the data with left_join because it will return all records matching. 
#the task wants only the full ingredient names NOT the code. I will now remove the code from the joint dataframe#

cake_ingredients_join <- cake_ingredient_code_lower %>%
  left_join(cake_ingredient_1961_new, by = "code") %>%
  relocate(cake) %>%
  select(-code)

head(cake_ingredients_join)

#I am just going to check the final table has distinct values so not to disturb the analyses

cake_ingredients_join %>%
  distinct(cake) 

cake_ingredients_join %>%
  distinct(ingredient)


cake_ingredients_join %>%
  distinct(measure)


cake_ingredients_join %>%
  distinct(ingredient)  


write_csv(cake_ingredients_join, ("cake_ingredients_join"))
