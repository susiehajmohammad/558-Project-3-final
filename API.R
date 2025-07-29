# api.R

#load necessary libraries
library(plumber)
library(readr)
library(dplyr)
library(tidymodels)

#read in the dataset and mutate
diabetes_data_reduced <- read_csv("diabetes_data.csv") %>% 
  mutate(
    Diabetes_binary = factor(Diabetes_binary, levels = c(0, 1), labels = c("No Diabetes", "Diabetes")),
    Sex = factor(Sex, levels = c(0, 1), labels = c("Female", "Male")),
    Age = factor(Age, levels = c(1:13), labels = c("18to24", "25to29", "30to34", "35to39", "40to44", "45to49", "50to54", "55to59", "60to64", "65to69", "70to74", "75to79", "80plus")),
    Education = factor(Education, levels = c(1:6), labels = c("Never attended or only kindergarten", "Elementary", "Some high school", "High school graduate", "Some college or technical school", "College graduate")),
    Income = factor(Income, levels = c(1:8), labels = c("< $10,000", "< $15,000", "< $20,000", "< $25,000", "< $35,000", "< $50,000", "< $75,000", "$75,000+"))
  ) %>%
  select(Diabetes_binary, Sex, Education, Income)

#load the trained model
final_model <- readRDS("logRegFit_1.rds")


#* @apiTitle Diabetes Prediction API

#* Predict diabetes probability based on input from user
#* @param Sex Default: most common value
#* @param Education Default: most common value
#* @param Income Default: most common value
#* @post /pred
function(Sex = "Female",
         Education = "College graduate",
         Income = "$75,000+") {
  
  # create dataframe with inputs that has only one row
  new_data <- data.frame(
    Sex = factor(Sex, levels = levels(diabetes_data_reduced$Sex)),
    Education = factor(Education, levels = levels(diabetes_data_reduced$Education)),
    Income = factor(Income, levels = levels(diabetes_data_reduced$Income))
  )
  
  #predict using the model
  prediction <- predict(final_model, new_data, type = "prob")
  
  return(list(prediction = prediction))
}

#* Info endpoint
#* @get /info
function() {
  list(
    name = "Susan Hajmohammad",
    url = "https://YOUR_GITHUB_URL_HERE"
  )
}

#example calls to test:
# curl -X POST "http://localhost:8000/pred?Sex=Male&Education=College%20graduate&Income=$75,000+"
# curl -X POST "http://localhost:8000/pred?Sex=Female&Education=Some%20high%20school&Income=<%20$25,000"
# curl -X POST "http://localhost:8000/pred?Sex=Male&Education=High%20school%20graduate&Income=<%20$50,000"
