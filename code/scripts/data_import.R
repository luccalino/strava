# Loading packages (install if not yet installed)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, strava, gtools, reticulate)

# Set the path to the Python executable file
use_python(python_path, required = T)

# Check the version of python
py_config()

# Remove files with no filename in csv file
activities <- read_csv("data/activities.csv")
activities <- activities[!is.na(activities$Filename), ]
activities$Filename <- paste0("data/",activities$Filename)
file.remove("data/activities.csv")
write_csv(activities, "data/activities.csv")

# Run the python script to rename activities
py_run_file("code/scripts/rename_activities.py")

# Unzip the renamed files
system("gunzip data/activities/*.gz")

# Run the bash script to convert fit to gpx
system("bash code/scripts/fits2gpxs.sh")

# Remove FIT files
system("rm data/activities/*.fit")

# Print stage of development
print("All good. Now importing the data. This can take a while...")

# Reading gpx data 
data <- process_data("data/activities")

# Saving as rData
save(data, file = "data/data.Rdata")

# Print stage of development
print("All done. Data is loaded.")

