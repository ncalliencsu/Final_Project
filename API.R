# This is a Plumber API. You can run the API by clicking the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/

# Endpoints define the R code that is executed in response to incoming requests.
# These endpoints correspond to HTTP methods and respond to incoming requests 
# that match the defined method.

#METHODS

#• @get - request a resource
#• @post - send data in body
#• @put - store / update data
#• @delete - delete resource
#• @head - no request body
#• @options - describe options
#• @patch - partial changes
#• @use - use all methods

library(plumber)
library(tidymodels)

#* @apiTitle Diabetes Prediction API
#* @apiDescription API for exploring Diabetes Dataset 

#Read in Data and Model Objects from Modeling File
data_in <- readRDS(file = "data_out.RDS")
RF_wkf_in <- readRDS(file = "RF_wkf_out.RDS")
RF_model_in <- readRDS(file = "RF_model_out.RDS")


#Fit Best Model to Entire Dataset
final_model <- RF_wkf_in |>
  finalize_workflow(RF_model_in) |>
  fit(data_in) 

#* Information Endpoint
#* @param msg The message to echo
#* @get /info

function(msg = "Metadata for Final Project") {
    list(msg = paste("Norman C. Allie"),
         msg = paste("URL for rendered github pages site "))
}
#http://


#* Prediction Endpoint
#* @param HighBP high blood pressure 
#* @param Diff_Walk difficulty walking 
#* @param Gen_Hlth general health
#* @param Phys_Act physically active
#* @param Alcohol heavy alcohol
#* @param BMI body mass index
#* @param Education education level
#* @param Income income level
#* @get /pred

 f <- function(HighBP = 0, Diff_Walk = 0, Gen_Hlth = 2, 
         Phys_Act = 1, Alcohol = 0, BMI = 28.38,
         Education = 6, Income = 8) {
  
  HighBP <- as.factor(HighBP)
  Diff_Walk <- as.factor(Diff_Walk)
  Gen_Hlth <- as.factor(Gen_Hlth)
  Phys_Act <- as.factor(Phys_Act)
  Alcohol <- as.factor(Alcohol)
  BMI <- as.integer(BMI)
  Education <- as.factor(Education)
  Income <- as.factor(Income)
  
  
  newdata <- data.frame(HighBP, Diff_Walk, Gen_Hlth, Phys_Act,
               Alcohol, BMI, Education, Income) 
  
  p <- predict(final_model, new_data = newdata)

    if(p == 0){
    print("Prediction: No Diabetes")
  } else print("Prediction: Diabetes")
    
}

#* Confusion Matrix Endpoint
#* @serializer png
#* @get /confusion

 function() {
  
  cm <- conf_mat(data_in |> mutate(estimate = final_model |> predict(data_in) |> pull()), #data
           Diabetes, #truth
           estimate)
  
  autoplot(cm, type = "heatmap")
}


 
