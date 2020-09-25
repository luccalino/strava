# Loading Rdata file
load(paste0(paste0(rname,"/export_data/data.Rdata")))

p <- ggplot() +
  geom_path(data = data, 
            aes(x = lon, y = lat, group = id),
            alpha = 0.3, size = 0.2, color = "red", lineend = "round", show.legend = FALSE) 