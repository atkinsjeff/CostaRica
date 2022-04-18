# making sense of landsat!
# 
require(raster)
require(sf)
require(fs)
require(purrr)
require(tidyverse)
library(maptools)
library(sp)
library(rgeos)
library(rgdal)
ras <- raster::raster("./data/costa_rica_modis_max_NDVI_wet_season_2020.tif")


x11()
plot(ras)

### bring in raster stack
ndvi <- raster::stack("rasterStack.tif")

x11()
raster::plot(ndvi)

# parrallelized code
cores <- 4
beginCluster(cores, type='SOCK')
ndvi.sd <- calc(ndvi, fun=sd)
endCluster()

# scale
ndvi.sd <- ndvi.sd * 0.0001
# plotting
x11()
raster::plot(ndvi.sd)
plot(res$geometry)

#####
CRS("+init=epsg:5456")
CRS("+init=epsg:5390")


# Lambert NW Costa Rica:
#     longitude origin 84 deg 20.000'
# scale 0.9999600
# False East 499800.00 m
# False North -885250.0 m
# Units = m 
#
# +a         Semimajor radius of the ellipsoid axis
# +b         Semiminor radius of the ellipsoid axis
# +datum     Datum name 
# +ellps     Ellipsoid name 
# +lat_0     Latitude of origin
# +lat_1     Latitude of first standard parallel
# +lat_2     Latitude of second standard parallel
# +lat_ts    Latitude of true scale
# +lon_0     Central meridian
# +over      Allow longitude output outside -180 to 180 range, disables wrapping 
# +proj      Projection name 
# +south     Denotes southern hemisphere UTM zone
# +units     meters, US survey feet, etc.
# +x_0       False easting
# +y_0       False northing
# +zone      UTM zone
(+proj=lcc +datum=NAD27 +no_dfs +units=m +x_0=499800.0 +y_0=-885250.0)
    
# importing the shapefiles
shp.files <- list.files("./data/areas_protegidas_ACG/", pattern = "*shp", full.names = TRUE)

ref.shp <- readOGR(shp.files[1])
# import them all
shapefile_list <- lapply(shp.files, read_sf)
# shapefile_list <- lapply(shapefile_list, crs, "+proj=lcc +datum=NAD27 +no_defs +units=m +x_0=499800.0 +y_0=-885250.0")
shapefile_list <-  lapply(shapefile_list, function(x) {st_crs(x) <- 5456; x})

shapefile_list <-  lapply(shapefile_list, spTransform, CRS("+init=epsg:9122"))

spTransform(ref.shp, CRS("+init=epsg:9122"))

spTransform(shapefile_list[[1]], CRS("+init=epsg:9122"))
dir_ls("./data/areas_protegidas_ACG/", glob = "*.shp") %>% 
    map(read_sf) %>%
    do.call(rbind, .) -> bounds

res <- dir_ls("./data/areas_protegidas_ACG/", glob = "*.shp") %>% 
    tibble(fname = .) %>%
    mutate(data = map(fname, read_sf)) %>%
    unnest(data) %>%
    st_as_sf() %>%
    st_set_crs(crs(ndvi))

write_sf(res, "./data/bounds.shp")


# import back
bounds <- read_sf("./data/bounds.shp")

x11()
plot(bounds)


#### for loops
## crop and mask
r2 <- crop(ndvi.sd, extent(res))
r3 <- mask(r2, SPDF)




















