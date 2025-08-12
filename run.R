library(azmetr)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(fs)
library(glue)
library(lubridate)
library(cli)


# station_info

station_list <- read_csv("azmet-station-list.csv")
station_list
source("R/utils.R")
source("R/azmet_daily_data_download.R")
source("R/azmet_hourly_data_download.R")
legacy_daily <- azmet_daily_data_download(station_list, "Tucson")
legacy_daily

legacy_hourly <- azmet_hourly_data_download(station_list, "Tucson")
legacy_hourly

# Run for all sites and save data out to CSV

station_names <- station_list$stn
out_dir <- dir_create("legacy")

#daily
purrr::walk(
  station_names,
  \(station) {
    legacy_daily <- azmet_daily_data_download(station_list, station)
    write_csv(
      legacy_daily$obs_dyly,
      path(out_dir, glue("obs_dyly-{snakecase::to_snake_case(station)}.csv"))
    )
    write_csv(
      legacy_daily$obs_dyly_derived,
      path(
        out_dir,
        glue("obs_dyly_derived-{snakecase::to_snake_case(station)}.csv")
      )
    )
    # wait a bit before scraping the next station to be friendly to resources
    Sys.sleep(3)
  },
  .progress = TRUE
)

#hourly
purrr::walk(
  station_names,
  \(station) {
    legacy_hourly <- azmet_hourly_data_download(station_list, station)
    write_csv(
      legacy_hourly$obs_hrly,
      path(out_dir, glue("obs_hrly-{snakecase::to_snake_case(station)}.csv"))
    )
    write_csv(
      legacy_hourly$obs_hrly_derived,
      path(
        out_dir,
        glue("obs_hrly_derived-{snakecase::to_snake_case(station)}.csv")
      )
    )
    # wait a bit before scraping the next station to be friendly to resources
    Sys.sleep(3)
  },
  .progress = TRUE
)
