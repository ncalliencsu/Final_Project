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
         msg = paste("https://ncalliencsu.github.io/Final_Project/EDA.html"))
}



#* Prediction Endpoint
#* @param High_BP high blood pressure 
#* @param Diff_Walk difficulty walking 
#* @param High_Chol high cholesterol
#* @param Heart_Cond heart condition
#* @param Stroke history of stroke
#* @param Phys_Act physically active
#* @param Alcohol heavy alcohol
#* @param BMI body mass index
#* @param Gen_Hlth general health
#* @param Age_Group age category
#* @get /pred

 f <- function(High_BP = 0,Diff_Walk = 0, High_Chol = 0,
               Heart_Cond = 0, Stroke = 0, Phys_Act = 1, 
               Alcohol = 0, BMI = 28.38, Gen_Hlth = 2, Age_Group = 8) {
  
 High_BP <- factor(High_BP)
 Diff_Walk <- factor(Diff_Walk)
 High_Chol <- factor(High_Chol)
 Heart_Cond <- factor(Heart_Cond)
 Stroke <- factor(Stroke)
 Phys_Act <- factor(Phys_Act)
 Alcohol <- factor(Alcohol)
 BMI <- as.integer(BMI)
 Gen_Hlth <- factor(Gen_Hlth)
 Age_Group <- factor(Age_Group)
  
  
  newdata <- data.frame(
    High_BP, 
    Diff_Walk, 
    High_Chol,
    Heart_Cond,
    Stroke,
    Phys_Act,
    Alcohol,
    BMI, 
    Gen_Hlth,
    Age_Group)
  
  p <- predict(final_model, new_data = newdata)

    if(p == 0){
    print("Prediction: No Diabetes")
  } else print("Prediction: Diabetes")
  

}

 # Example Function Calls for Prediction Endpoint

  #http://localhost:8000/pred?High_BP=1&Diff_Walk=0&High_Chol=1&Heart_Cond=1&Stroke=1&Phys_Act=0&Alcohol=1&BMI=20&Gen_Hlth=3&Age_Group=7
 
 #http://localhost:8000/pred?High_BP=0&Diff_Walk=1&High_Chol=1&Heart_Cond=0&Stroke=0&Phys_Act=1&Alcohol=0&BMI=75&Gen_Hlth=1&Age_Group=9
 
 #http://localhost:8000/pred?Heart_Cond=0&Stroke=0&Phys_Act=1&Alcohol=0&BMI=75&Gen_Hlth=1&Age_Group=4
 
 
 
#* Confusion Matrix Endpoint
#* @serializer png
#* @get /confusion

 function() {
  
  cm <- conf_mat(data_in |> mutate(estimate = final_model |> predict(data_in) |> pull()), #data
           Diabetes, #truth
           estimate)
  
  print(autoplot(cm, type = "heatmap"))
}


 
