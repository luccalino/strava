# Strava data computations and visualisations
This repository uses sports activity data from Strava, manipulates it and generates several outputs/visualisations. Hava a look.

Preliminary remarks: To access the material in its entirety, you need to have a working installation of R and Python3 installed.

## Data import
There are two methods elaboraed here to get your Strava data.

### 1. Request your archive
1. Request your Strava archive via E-Mail. In your Strava account: Settings -> My Account -> Download or Delete Your Account (Get started) -> Request Your Archive.
2. Wait for the E-Mail and download the archive.
3. Fork and download this repository.
4. Copy the _activities_ folder and _activities.csv_ file into the data folder in this repository.
5. Open the _makefile.R_ (in the code folder) and set the working directory to the folder where you have your code and data folders located. Change the _python_path_ variable to the location where you have python3 installed.
6. Change _import_ = 0 to _import_ = 1. Save and run the file. This can take a while.
7. Cool, your data is now loaded and ready to be processed.

### 2. Scrape information through the Strava API
More on this soon.

## Passed
Passed is a programm that automatically recognises if you have already climbed a mountain pass in Switzerland, France or Italy (with the bike obviously...). Since there is a myraid of passes, it is challenging to keep track of your stats. This programm approaches this challenge systematically and automatically. If you want to know your Stats, switch the variable _passed_ to 1 (0 by default) in the _makefile.R_. **Note**: Since data is already loaded, change _import_ to 0. You also want to switch _scrape_ to 1 to get fresh pass data. If switched on, this will scrape pass info from quäldich.de. There is a working file provided within this folder. Thus, scraping pass info is not required. Have a look at your stats in the _plot_ folder.

## Ridges
More to come soon.

## Maps
More to come soon.
