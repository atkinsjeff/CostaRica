# download script
# look to here:  https://cran.r-project.org/web/packages/MODISTools/vignettes/modistools-vignette.html
library(MODISTools)
bands <- mt_bands(product = "MOD13Q1")
head(bands)
# get the product we want
bands <- mt_bands(product = "MOD13Q1")
head(bands)

# look at dates
dates <- mt_dates(product = "MOD13Q1", lat = 11, lon = -85.5)
head(dates)

# download the MODIS land cover (IGBP) and NDVI data
# for a region around the French city and basin of Arcachon
cr_ndvi <- mt_subset(product = "MOD13Q1",
                          lat = 11,
                          lon =  -85.5,
                          band = "250m_16_days_NDVI",
                          start = "2020-01-01",
                          end = "2020-01-31",
                          km_lr = 25,
                          km_ab = 25,
                          site_name = "Costa Rica",
                          internal = TRUE,
                          progress = TRUE)


# test batch download

# create data frame with a site_name, lat and lon column
# holding the respective names of sites and their location
df <- data.frame("site_name" = paste("test",1:2), stringsAsFactors = FALSE)
df$lat <- 40
df$lon <- -110

# an example batch download data frame
head(df)
#>   site_name lat  lon
#> 1    test 1  40 -110
#> 2    test 2  40 -110
# test batch download
subsets <- mt_batch_subset(df = df,
                           product = "MOD13Q1",
                           band = "250m_16_days_NDVI",
                           km_lr = 1,
                           km_ab = 1,
                           start = "2004-01-01",
                           end = "2004-12-30",
                           internal = TRUE)

subsets <- mt_batch_subset(df = cr_ndvi,
                           product = "MOD13Q1",
                           band = "250m_16_days_NDVI",
                           km_lr = 1,
                           km_ab = 1,
                           start = "2020-01-01",
                           end = "2020-01-31",
                           internal = TRUE)
