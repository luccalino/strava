# Strava data processing
1. Download or fork this repository.
2. Request your Strava archive from the settings page from your Strava Account. Wait for the E-Mail and download the archive.
3. Copy the activities folder and activities.csv file into the data folder in this repository.
4. Open the makefile.R (in the code folder) and set the working directory to the folder where you have your code and data folders located.
5. Choose what features you want to run by changing the 0s with 1s.
5. Save and run the makefile.R

# Features
## Passed
Passed is an app that automatically recognises if you have passed a mountain pass (with the bike obviously...). If you want to know your Stats, switch the variable 'passed' to 1 (0 by default). Note: You also want to switch 'scrape' to 1 to get fresh pass data. If switched on, this will scrape the pass data from quäldich.de. The plot will appear in the plot folder.

## Ridges
More to come soon.

### Feedback is very welcome :)
