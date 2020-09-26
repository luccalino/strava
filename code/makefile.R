# Clear environment to start from a white page
remove(list = ls())

# Set working directory (Your working directory!)
setwd("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/strava/data/friends/")

# Select variables
rname = "Your_name" 
country = "schweiz" #"italien" #"frankreich"

# Table of contents (1: Execute; 0: Chill...)
import = 0 # Data import
ridges = 0 # Plots ridges
passed = 0 # Plots Pass Checkbook 
scrape = 0 # Scrape Pass Info from quäldich.de

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
