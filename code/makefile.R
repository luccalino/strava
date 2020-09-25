# Clear environment to start from a white page
remove(list = ls())

# Set working directory
setwd("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/strava/data/friends/")

# Select variables
rname = "romy_pollard" #"manuel_luethi "#"beni_kraehenmann" #"fabian_ruethi"
country = "schweiz" #"italien" #"frankreich"
type = ""

# Table of contents (1: Yes; 0: No)
import = 1
ridges = 0
passed = 0
scrape = 0
maps = 0

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
if (maps == 1) {
  source("code/scripts/maps.R")
}