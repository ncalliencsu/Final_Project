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
RF_model_in <- readRDS(file = "RF_model_out.RDS")
RF_wkf_in <- readRDS(file = "RF_wkf_out")

#Fit Best Model to Entire Dataset
final_model <- RF_wkf_in |>
  finalize_workflow(RF_model_in) |>
  fit(data_in)



#* Information Endpoint
#* @param msg The message to echo
#* @get /info

function(msg = "") {
    list(msg = paste0("The message is: '", msg, "'"))
}

#* Prediction Endpoint
#* @param HBP high blood pressure 
#* @param DWALK difficulty walking 
#* @param GHLTH general health
#* @param PHYS physically active
#* @param ALCH heavy alcohol
#* @param BMI body mass index
#* @param EDU education level
#* @param INC income level
#* @get /pred

function(HBP = 0, DWALK = 0, GHLTH = 2, 
         PHYS = 3.185, ALCH = 0, BMI = 28.38,
         EDU = 6, INC = 8) {
  
  newdata <- c(HBP, DWALK, GHLTH, PHYS,
               ALCH, BMI, EDU, INC)
  
  predict(final_model, newdata, type = "response")
    
}


#* Plot a Confusion Matrix
#* @serializer png
#* @get /confusion

function() {
  
  conf_mat()
  
 
  
}


