library(azmetr)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(fs)
library(glue)
library(lubridate)
library(cli)
library(snakecase)
library(tidyr)


# station_info

station_list <- read_csv("azmet-station-list.csv")
station_list
source("R/utils.R")
source("R/azmet_daily_data_download.R")
source("R/azmet_hourly_data_download.R")
# legacy_daily <- azmet_daily_data_download(station_list, "Phoenix Greenway", years = 2018)
# legacy_daily$obs_dyly_duplicated

# legacy_hourly <- azmet_hourly_data_download(
#   station_list,
#   "Maricopa",
#   years = 2018
# )
# legacy_hourly$obs_hrly_duplicated
# Run for all sites and save data out to CSV

station_names <- station_list$stn
out_dir <- dir_create("legacy")

#daily (through 2019)
purrr::walk(
  station_names,
  \(station) {
    legacy_daily <- azmet_daily_data_download(
      station_list,
      station,
      years = 1986:2019
    )
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
    if (nrow(legacy_daily$obs_dyly_duplicated) > 0) {
      write_csv(
        legacy_daily$obs_dyly_duplicated,
        path(
          out_dir,
          glue("obs_dyly_duplicated-{snakecase::to_snake_case(station)}.csv")
        )
      )
    }
    # wait a bit before scraping the next station to be friendly to resources
    Sys.sleep(3)
  },
  .progress = TRUE
)

#hourly
purrr::walk(
  station_names,
  \(station) {
    legacy_hourly <- azmet_hourly_data_download(
      station_list,
      station,
      years = 1986:2019
    )
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
    if (nrow(legacy_hourly$obs_hrly_duplicated) > 0) {
      write_csv(
        legacy_hourly$obs_hrly_duplicated,
        path(
          out_dir,
          glue("obs_hrly_duplicated-{snakecase::to_snake_case(station)}.csv")
        )
      )
    }
    # wait a bit before scraping the next station to be friendly to resources
    Sys.sleep(3)
  },
  .progress = TRUE
)

# Post processing with Matt Harmon's python code to add additional mising derived variables
library(reticulate)
# According to docs, using virtualenvs isn't required anymore and py_require()
# is supposed to find python automatically, but it doesn't work for me.

# virtualenv_create("azmet")
use_virtualenv("azmet")
# Load python packages
py_require(c("csv", "decimal", "math", "re"))
# Source python script as R functions
source_python("csvParseAndProcess.py")

# # Just a single site
# out <- updateDerived(
#   path_obs_hrly = "legacy/obs_hrly-tucson.csv",
#   path_derived_hrly = "legacy/obs_hrly_derived-tucson.csv",
#   path_obs_dyly = "legacy/obs_dyly-tucson.csv",
#   path_derived_dyly = "legacy/obs_dyly_derived-tucson.csv"
# )
# out
# # remove updated files for now.  With batch processing below, we'll *replace*
# # the derived data with the updated one
# fs::file_delete(out)

# reconstruct file names to provide inputs to pwalk() over
files_df <- tibble(
  path_obs_hrly = path(
    out_dir,
    glue::glue("obs_hrly-{snakecase::to_snake_case(station_names)}.csv")
  ),
  path_derived_hrly = path(
    out_dir,
    glue::glue("obs_hrly_derived-{snakecase::to_snake_case(station_names)}.csv")
  ),
  path_obs_dyly = path(
    out_dir,
    glue::glue("obs_dyly-{snakecase::to_snake_case(station_names)}.csv")
  ),
  path_derived_dyly = path(
    out_dir,
    glue::glue("obs_dyly_derived-{snakecase::to_snake_case(station_names)}.csv")
  ),
)

# Apply updateDerived to all files
pwalk(files_df, updateDerived)

# Remove obs_(hrly/dyly)_derived-(station).csv to only keep the updated versions
derived_orig <- c(
  path(
    "legacy",
    glue::glue("obs_dyly_derived-{snakecase::to_snake_case(station_names)}.csv")
  ),
  path(
    "legacy",
    glue::glue("obs_hrly_derived-{snakecase::to_snake_case(station_names)}.csv")
  )
)
fs::file_delete(derived_orig)

# Pull together any files containing duplicates
dir_ls(out_dir, regexp = "dyly_duplicated") |>
  read_csv() |>
  left_join(
    station_list |>
      select(station_name = stn, station_number = stn_no),
    by = join_by(station_number)
  ) |>
  select(station_name, station_number, everything()) |>
  arrange(station_number, obs_year, obs_doy) |>
  write_csv("azmet_dyly_duplicates.csv")

dir_ls(out_dir, regexp = "hrly_duplicated") |>
  map(\(x) {
    read_csv(x) |> mutate(station_number = as.numeric(station_number))
  }) |>
  list_rbind() |>
  mutate(station_number = as.integer(station_number)) |>
  left_join(
    station_list |>
      select(station_name = stn, station_number = stn_no)
  ) |>
  select(station_name, station_number, everything()) |>
  write_csv("azmet_hrly_duplicates.csv")

# Zip files for upload
# zip::zip("azmet_legacy_1987-2019.zip", files = "legacy")
