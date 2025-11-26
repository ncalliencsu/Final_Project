# start from the rstudio/plumber image
FROM rstudio/plumber

# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev pandoc 
    
    
# install plumber, tidymodels
RUN R -e "install.packages(c('tidymodels', 'plumber', 'ranger'))"

# copy API.R from the current directory into the container
COPY API.R API.R

#copy dataset, workflow and model from the current directory into the container
COPY data_out.RDS data_out.RDS
COPY RF_wkf_out.RDS RF_wkf_out.RDS
COPY RF_model_out.RDS RF_model_out.RDS

# open port to traffic
EXPOSE 8000

# when the container starts, start the API.R script
ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('API.R'); pr$run(host='0.0.0.0', port=8000)"]
