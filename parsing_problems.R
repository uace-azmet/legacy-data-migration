#This is much slower than the functions because read_csv(<list of URLs>) is much
#faster than map(<list of URLs>, read_csv), but doing it the latter way is more
#helpful for isolating parsing issues with `problems()`

# This is for hourly data but could be modified for daily as well

library(tidyverse)


stn_list <- read_csv("azmet-station-list.csv")

col_names_pre <-
  c(
    "obs_year",
    "obs_doy",
    "obs_hour",
    "obs_hrly_temp_air",
    "obs_hrly_relative_humidity",
    "obs_hrly_vpd",
    "obs_hrly_sol_rad_total",
    "obs_hrly_precip_total",
    "temp_soil_shallow",
    "temp_soil_deep",
    "obs_hrly_wind_spd",
    "obs_hrly_wind_vector_magnitude",
    "obs_hrly_wind_vector_dir",
    "obs_hrly_wind_vector_dir_stand_dev",
    "obs_hrly_wind_spd_max",
    "obs_hrly_derived_eto_azmet", # Derived: reference ETo
    "heat_units" # Derived: 30/12.8 C (Not in modern database)
  )

col_names_post <-
  c(
    "obs_year",
    "obs_doy",
    "obs_hour",
    "obs_hrly_temp_air",
    "obs_hrly_relative_humidity",
    "obs_hrly_vpd",
    "obs_hrly_sol_rad_total",
    "obs_hrly_precip_total",
    "obs_hrly_temp_soil_10cm", #4 inches
    "obs_hrly_temp_soil_50cm", #20 inches
    "obs_hrly_wind_spd",
    "obs_hrly_wind_vector_magnitude",
    "obs_hrly_wind_vector_dir",
    "obs_hrly_wind_vector_dir_stand_dev",
    "obs_hrly_wind_spd_max",
    "obs_hrly_derived_eto_azmet", # Derived: reference ETo
    "obs_hrly_actual_vp",
    "obs_hrly_derived_dwpt" # Derived: dewpoint, hourly average
  )

# stn_name <- stn_list$stn[1]

# For every station...
out <- map(stn_list$stn, \(x) {
  stn_info <- subset(x = stn_list, subset = stn == stn_name)

  stn_no <- as.character(select(stn_info, stn_no))
  if (as.integer(select(stn_info, stn_no)) < 10) {
    stn_no <- paste0("0", stn_no)
  }

  # Set the range of years for which to download data for the selected station
  stn_yrs <- as.integer(select(stn_info, start_yr)):as.integer(select(
    stn_info,
    end_yr
  ))

  # Set the base URL of the AZMET data
  baseurl <- "http://azmet.arizona.edu/azmet/data/"

  # Set the suffix of the data file to be downloaded
  suffix <- "rh.txt"

  # Construct URLs for each year
  urls_pre_2002 <- paste0(
    baseurl,
    stn_no,
    substr(as.character(stn_yrs[stn_yrs <= 2002]), 3, 4),
    suffix
  )
  urls_post_2002 <- paste0(
    baseurl,
    stn_no,
    substr(as.character(stn_yrs[stn_yrs > 2002]), 3, 4),
    suffix
  )

  # for every year pre 2002 ...
  problems_pre <- map(urls_pre_2002, \(url) {
    #read in and save out the problems()
    read_csv(
      url,
      col_names = col_names_pre,
      col_types = cols(
        obs_year = col_character(),
        obs_doy = col_character()
      ),
      trim_ws = TRUE
    ) |>
      problems()
  }) |>
    set_names(urls_pre_2002)

  # For every post 2002 url...
  problems_post <- map(urls_post_2002, \(url) {
    # read it in and save out problems()
    read_csv(
      url,
      col_names = col_names_post,
      col_types = cols(
        obs_year = col_character(),
        obs_doy = col_character()
      ),
      trim_ws = TRUE
    ) |>
      problems()
  }) |>
    set_names(urls_post_2002)

  # Combine all the problems() and get rid of any empty one (i.e. URLs that had
  # no parsing issues from readr)
  c(problems_pre, problems_post) |> discard(\(x) nrow(x) == 0)
}) |>
  set_names(stn_list$stn)

#A list of stations.  Each station is a list of years with each element being
#the return value of `readr::problems()` from parsing that CSV file.
out
