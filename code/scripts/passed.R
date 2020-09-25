# Loading packages (install if not yet installed)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, rvest, raster, rgdal, rgeos, strava, sp, gtools, mdthemes)

# Clear environment to start from a white page
#remove(list = ls())

# Set working directory
#setwd("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/strava/")

# Select name
#rname = "beni_kraehenmann" #"manuel_luethi "#"beni_kraehenmann" #"fabian_ruethi"
#country = "schweiz" #"italien" #"frankreich"

# Scarping pass details? (1: Yes; 0: No)
#scrape = 0

######### Scraping quälldich.de #########
if (scrape == 1) {

  countries <- c("schweiz","frankreich","italien")
  
  for (c in 1:length(countries)) {
      
    start_page <- read_html(paste0("https://www.quaeldich.de/regionen/",countries[c],"/paesse/?n=7000"))
    list_of_urls <- start_page %>% 
      html_nodes(".col-sm-5:nth-child(1) a") %>%
      html_attr(name = "href") %>%
      as.data.frame() %>%
      unique()
    
    names(list_of_urls)[1] <- "link"
    
    list_of_names <- start_page %>% 
      html_nodes(".col-sm-5:nth-child(1) a") %>%
      html_text() %>%
      as.data.frame()
    
    names(list_of_names)[1] <- "name"
    
    list_of_altitudes <- start_page %>% 
      html_nodes(".hidden-xs.col-sm-2") %>%
      html_text() %>%
      as.data.frame() 
    
    names(list_of_altitudes)[1] <- "altitude"
    list_of_altitudes$altitude <- trimws(list_of_altitudes$altitude, which = c("both"))
    list_of_altitudes$altitude <- gsub(" m","",list_of_altitudes$altitude)
    
    ds <- cbind(list_of_names, list_of_altitudes, list_of_urls)
    
    for (l in 1:nrow(ds)) {
  
  page <- read_html(paste0("https://www.quaeldich.de",ds$link[l]))

  node <- page %>%
    html_nodes(".coords a")
  ds$coords[[l]] <- ifelse(length(node)!= 0,
                                   node[1] %>% 
                                     html_attr(name = "href"),
                                   NA
  ) 
  
  ds$coords[[l]] <- gsub("http://www.google.com/maps/place/","",ds$coords[[l]])
  
  node <- page %>%
    html_nodes("#tag-cloud a")
  ds$type[[l]] <- ifelse(length(node)!= 0,
                           node[1] %>% 
                             html_text(),
                           NA
  ) 
  
  node <- page %>% 
    html_nodes("h1 img") 
  ds$country[[l]] <- ifelse(length(node)!= 0,
                         node %>% 
                           html_attr(name = "src"),
                         NA
  )
  
  ds$country <- gsub("https://www.quaeldich.de/webinclude/img/flag/","",ds$country) 
  ds$country <- gsub(".png","",ds$country) 
  
  node <- page %>% 
    html_nodes(".pass-regionen a:nth-child(1)") 
  ds$region_1[[l]] <- ifelse(length(node)!= 0,
                            node %>% 
                             html_text(),
                            NA
  )

  node <- page %>% 
    html_nodes(".pass-regionen a:nth-child(2)") 
  ds$region_2[[l]] <- ifelse(length(node)!= 0,
                           node %>% 
                             html_text(),
                           NA
  )
  
  node <- page %>% 
    html_nodes(".pass-regionen a:nth-child(3)") 
  ds$region_3[[l]] <- ifelse(length(node)!= 0,
                             node %>% 
                               html_text(),
                             NA
  )
  
  node <- page %>% 
    html_nodes(".pass-regionen a:nth-child(4)") 
  ds$region_4[[l]] <- ifelse(length(node)!= 0,
                             node %>% 
                               html_text(),
                             NA
  )
  
  node <- page %>% 
    html_nodes(".pass-regionen a:nth-child(5)") 
  ds$region_5[[l]] <- ifelse(length(node)!= 0,
                             node %>% 
                               html_text(),
                             NA
  )
  
  print(l)
  
}
    
    # Adjustments
    ds <- separate(ds, coords, c("lat", "lon"), ",", remove = TRUE)
    ds$lat <- as.numeric(ds$lat)
    ds$lon <- as.numeric(ds$lon)
    ds$altitude <- as.numeric(ds$altitude)
    ds$id <- row.names(ds)
    
    # Manual adjustments
    #ds$lat[ds$name == "Col du Grand St. Bernard"] <- 45.893939
    #ds$lon[ds$name == "Col du Grand St. Bernard"] <- 7.186463
    
    #ds$lat[ds$name == "Simplonpass"] <- 46.249959
    #ds$lon[ds$name == "Simplonpass"] <- 8.031432
    
    # Remove relevant missing values
    ds <- ds %>% 
      drop_na(lat, lon)
    
    # Removing unused variables
    rm(list = c('list_of_altitudes','list_of_names','list_of_urls','node','page','start_page'))
    
    # Saving as rData
    save(ds, file = paste0("auxiliary_data/pass_data_",countries[c],".Rdata"))
  
  }
  
}

# Loading pass data
load(paste0("auxiliary_data/pass_data_",country,".Rdata"))

# Drop Schotter and Sackgasse from pass data
pass_info <- subset(ds, is.na(type) | type == "quaeldich-Reise" | type == "Pavé")

# Define pass ID
pass_info$id <- NULL
pass_info$id <- as.integer(seq(length = nrow(pass_info)))
pass_info <- pass_info %>%
  dplyr::select(id, everything())
row.names(pass_info) <- pass_info$id

### Source: https://www.neonscience.org/field-data-polygons-centroids ###

# Set the radius for the plots (radius in meters/ WGS84-Scaling Factor)
radius = 70/10000

# Define the plot edges based upon the plot radius 
yPlus <- pass_info$lat+radius
xPlus <- pass_info$lon+radius
yMinus <- pass_info$lat-radius
xMinus <- pass_info$lon-radius

# Calculate polygon coordinates for each plot centroid. 
square = cbind(xMinus, yPlus,  # NW corner
               xPlus, yPlus,  # NE corner
               xPlus, yMinus,  # SE corner
               xMinus, yMinus, # SW corner
               xMinus, yPlus)  # NW corner again - close ploygon

# Extract the plot ID information
ID = as.character(pass_info$id)

# Create SpatialPolygons from coordinates
pass_polygons <- SpatialPolygons(mapply(function(poly, id) {
  xy <- matrix(poly, ncol=2, byrow=TRUE)
  Polygons(list(Polygon(xy)), ID = id)
}, 
split(square, row(square)), ID), proj4string = CRS(as.character("+proj=longlat +datum=WGS84")))

# Preliminary plot
plot(pass_polygons)

######### Riding data #########
# Import strava activity data if not yet done
# if(!file.exists(paste0("data/friends/",rname,"/export_data/data.Rdata"))) {
#   
#   # Loading GPX files
#   rides <- process_data(paste0("data/friends/",rname,"/export_data/activities"))
#   
#   # Saving as Rdata
#   save(rides, file = paste0("data/friends/",rname,"/export_data/data.Rdata"))
#   
# }

# Loading Rdata file
load(paste0(rname,"/export_data/data.Rdata"))

# Select only rides (or NA)
#types <- unique(rides$type)
#rides_new <- subset(rides, is.na(type) | type == "Ride" | type == "Ride 3")
#rides$id_new <- as.integer(seq(length = nrow(rides)))
#row.names(rides) <- rides$id_new
  
# Select relevant variables
rides <- data %>% 
  dplyr::select(lon, lat, id, type)
  
# Generate SpatialPoints dataframe with WGS84 as CRS
coordinates(rides) <- c("lon","lat")
rides_spatial <- as(rides,"SpatialPoints")
proj4string(rides_spatial) <- CRS("+proj=longlat +datum=WGS84")
proj4string(rides_spatial) <- proj4string(pass_polygons)
  
# Check if points are in pass polygone
output <- over(rides_spatial, pass_polygons)

# Keep only passed and unique SpatialPoints
passed <- unique(as.data.frame(na.omit(output)))
names(passed)[1] <- "id"
passed$passed <- "Check!"

# Merge passed df with Pass information df 
merged_passes <- left_join(pass_info, passed, by = "id")

# Fill NAs (= not (yet!) passed passes) with "No"
merged_passes$passed <- ifelse(is.na(merged_passes$passed), "No", "Check!")

# Sort merged df in descending order and select highest passes for plotting
plot_data <- merged_passes %>% 
  arrange(desc(altitude)) %>%
  head(.,75)

# Add altitude category
plot_data$categorie <- ifelse(plot_data$altitude >= 2000, "Alpine catégorie (AC)", 
                              ifelse(plot_data$altitude < 2000 & plot_data$altitude >= 1700, "Haute catégorie (HC)", 
                                     ifelse(plot_data$altitude < 1700 & plot_data$altitude >= 1500, "Première catégorie (PC)",
                                            "Else"))) 

######### Plotting #########
# Plotting prelims
green = "springgreen4"
red = "tomato2"

capitalize <- function(x) {
  x <- strsplit(x, " ")
  for (i in seq(along = x)) {
    substr(x[[i]], 1, 1) <- toupper(substr(x[[i]], 1, 1))
  }
  sapply(x, function(z) paste(z, collapse = " "))
}

rname_new <- capitalize(gsub("_"," ",rname)) 
country_new <- capitalize(country) 

# Plotting Checkbook 
p <- ggplot(data = plot_data, aes(x = reorder(name, +altitude), y = altitude)) + 
  facet_grid(. ~ reorder(categorie, +altitude), switch = "x", scales = "free_x", space = "free_x") +
  geom_text(aes(label = paste0(altitude,"")), hjust = -.4, angle = 90, size = 2, fontface = ifelse(plot_data$passed == "Check!", "bold", "plain")) +
  geom_segment(aes(y = min(altitude)-50, 
                   x = name, 
                   yend = altitude, 
                   xend = name,
                   color = passed),
               size = 4, lineend = "butt") +
  scale_y_continuous(limits = c(min(plot_data$altitude)-50, max(plot_data$altitude)+50), expand = c(0, 0)) +
  scale_color_manual(values = c(green, red)) +
  ylab("") +
  xlab("") +
  labs(title = "Passed: Cycling Pass Checkbook",
       subtitle = paste0("Cyclist: ",rname_new,"; Country: ",country_new,"\nData sources: Strava/quäldich.de")) +
  labs(color = "Passed?") +
  theme_minimal() +
  theme(strip.placement = "outside",
        strip.text.x = element_text(size = 16, face = "bold", colour = "black"),
        axis.title.x = element_blank(),
        axis.text.y = element_blank(), 
        axis.text.x = element_text(face="bold", size = 6, angle = 45, hjust = 0.99), #element_text(size = 6, angle = 45, hjust = 0.99),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())
p

ggsave(plot = p, 
       width = 297,
       height = 210,  
       unit = "mm", 
       dpi = 400, 
       filename = paste0(rname,"/plots/passed_",country,".png"))

# Plotting spatial map
#ggplot() +
  # geom_path(data = rides,
  #            aes(long, lat, group = id), size = 2, show.legend = FALSE) +
  # geom_point(data = rides,
  #            aes(long, lat, group = id), color = "black", show.legend = FALSE) +
#  geom_polygon(data = pass_polygons,
#               aes(long, lat, group = id), show.legend = FALSE, color = "red", fill = NA) 
#
#  coord_map(xlim=c(xmin,xmax), ylim=c(ymin,ymax))

######### Debugging #########
#ggsave(plot = p, 
#       width = 297,
#       height = 210,  
#       unit = "mm", 
#       dpi = 400, 
#       filename = paste0("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/strava/data/friends/",rname,"/plots/passt_2.png"))

#Plotting polygons
#data <- process_data(paste0("data/friends/",rname,"/export_data/activities"))
#rides <- read.csv("/Users/laz/Library/Mobile Documents/com~apple~CloudDocs/Projects/strava/data/rides_n_runs_20200913.csv", header = TRUE)
# 
# x_center = 8.414970 # 9.330371 #7.186463 #8.034470 #9.837870
# y_center = 46.572400 #46.505538 #45.893939 #46.251000 #46.582500
# 
# xmin= x_center - 0.15
# xmax= x_center + 0.15
# ymin= y_center - 0.15
# ymax= y_center + 0.15
# 
# ggplot() +
#   geom_path(data = data,
#              aes(lon, lat, group = id), size = 2, show.legend = FALSE) +
#   geom_point(data = data,
#              aes(lon, lat, group = id), color = "black", show.legend = FALSE) +
#   geom_polygon(data = pass_polygons,
#                aes(long, lat, group = id), show.legend = FALSE, color = "red", fill = NA) +
#   coord_map(xlim=c(xmin,xmax), ylim=c(ymin,ymax))

    

