#A REST API (Representational State Transfer Application Programming Interface) is a set of rules #for building web services that allow systems to communicate over HTTP. REST APIs use standard HTTP methods like GET, POST, PUT, and DELETE to perform operations on resources, which are typically #represented as URLs. 

#REST emphasizes stateless communication, meaning each request contains all the information needed for the server to process it, and responses are usually formatted in JSON or XML. REST APIs are widely used for web and mobile applications due to their simplicity, scalability, and #compatibility with web standards.

# This is a Plumber API. You can run the API by clicking the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/

#Read in Data and Model Objects from Modeling File
data_in <- readRDS(file = "data_out.RDS")
RF_model_in <- readRDS(file = "RF_model_out.RDS")
RF_wkf_in <- readRDS(file = "RF_wkf_out")

#Fit Best Model to Entire Dataset
final_model <- RF_wkf_in |>
  finalize_workflow(RF_model_in) |>
  fit(data_in)

library(plumber)

#* @apiTitle Final_Project
#* @apiDescription Predictive Model of Diabetes Data

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
    list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function() {
    rand <- rnorm(100)
    hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
    as.numeric(a) + as.numeric(b)
}

# Programmatically alter your API
#* @plumber
function(pr) {
    pr %>%
        # Overwrite the default serializer to return unboxed JSON
        pr_set_serializer(serializer_unboxed_json())
}
