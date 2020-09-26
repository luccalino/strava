# Clear environment to start from a white page
remove(list = ls())

############################# Adjust only this part ################################ 
# Set working directory (Your working directory!)
setwd("YOUR_WORKING_DIR")

# Select variables
rname = "YOUR_NAME" 
country = "schweiz" #"italien" #"frankreich"
python_path = "YOUR_PYTHON_PATH" # Your path where the python executable is located

# Table of contents (1: Execute; 0: Chill...)
import = 0 # Data import
ridges = 0 # Plots ridges
passed = 0 # Plots Pass Checkbook 
scrape = 0 # Scrape Pass Info from quäldich.de
####################################################################################

# Execute scripts
if (import == 1) {
  source("code/scripts/data_import.R")
}
if (ridges == 1) {
  source("code/scripts/ridges.R")
}
if (passed == 1) {
  source("code/scripts/passed.R")
}
