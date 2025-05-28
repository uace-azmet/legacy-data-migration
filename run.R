library(azmetr)
library(readr)
library(dplyr)
library(bench)

station_info

station_list <- read_csv("azmet-station-list.csv")
station_list
source("R/azmet_daily_data_download.R")
source("R/azmet_hourly_data_download.R")
legacy_daily <- azmet_daily_data_download(station_list, "Tucson")
legacy_daily

legacy_hourly <- azmet_hourly_data_download(station_list, "Tucson")
legacy_hourly
