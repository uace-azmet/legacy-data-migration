# https://github.com/awslabs/open-data-docs/tree/main/docs/noaa/noaa-gefs-pds
library(arrow)
library(lubridate)
library(stringr)
library(terra)
library(tidyr)
library(exactextractr)
library(azmetr)
library(sf)

bucket <- "noaa-gefs-pds"
date <- today()
cycle <- "00"

#explore bucket to figure out file naming system
s3 <- s3_bucket(
  bucket = glue::glue(
    '{bucket}/gefs.{format(date, "%Y%m%d")}/{cycle}/atmos/pgrb2ap5/'
  ),
  anonymous = TRUE,
  region = "us-east-1"
)
s3$ls()

#all models all forecast hours up to 48 hrs
paths <-
  tidyr::expand_grid(
    bucket = bucket,
    date = date,
    cycle = cycle,
    ensemble_num = formatC(1:30, flag = 0, width = 2),
    hour = formatC(seq(0, 48, by = 3), flag = 0, width = 3)
  ) |>
  # /vsis3/ didn't work for me, but doesn't matter since these are public
  glue::glue_data(
    '/vsicurl/http://{bucket}.s3.amazonaws.com/gefs.{format(date, "%Y%m%d")}/{cycle}/atmos/pgrb2ap5/gep{ensemble_num}.t00z.pgrb2a.0p50.f{hour}'
  )


eg <- rast(paths[1])
plot(eg[[64]]) #the world

#get points for stations from azmetr
station_circles <- station_info |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  st_transform(crs = 2223) |> #transform to units of feet https://epsg.io/2223
  #create buffer in feet
  st_buffer(1000)

#what the layers are for ensemble (different from control)
#https://www.nco.ncep.noaa.gov/pmb/products/gens/gep01.t00z.pgrb2a.0p50.f000.shtml
exact_extract(
  eg[[c(64, 65)]], #temp and rh 2m above ground
  station_circles,
  fun = "mean",
  append_cols = TRUE
) |>
  as_tibble()

#alternative to s3 bucket is to use grib filtering to download files with just needed layers and within bounding box for AZ (or even just for AZMet stations + buffer):
# https://nomads.ncep.noaa.gov/gribfilter.php?ds=gefs_atmos_0p50a
