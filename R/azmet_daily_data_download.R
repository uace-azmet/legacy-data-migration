# FUNCTION FOR DOWNLOADING AND FORMATTING DAILY AZMET DATA

# Authors:
# Jeremy Weiss, Climate and Geospatial Extension Scientist
# School of Natural Resources and the Environment
# University of Arizona
# 520-626-8063, jlweiss@email.arizona.edu
#
# Michael Crimmins, Climate Science Extension Specialist
# Department of Soil, Water, and Environmental Science
# University of Arizona
# 520-626-4244, crimmins@email.arizona.edu
#
# Eric R. Scott
# Communications and Cyber Technologies
# University of Arizona
# ORCID: 0000-0002-7430-7879

# This function downloads daily AZMET data for an individual station, formats
# data into a dataframe, checks for missing or duplicate dates or other
# oddities, and writes the station data dataframe to the current environment

azmet_daily_data_download <- function(stn_list, stn_name) {
  # SETUP --------------------

  # AZMET data format changes between the periods 1987-2002 and 2003-present, as
  # the number of variables measured / reported and their order in the data file
  # are slightly different. We will set up a column name string that matches the
  # variables and variable order of the latter period.

  # Set column name string for the 2003-present period. This list can be found
  # at http://ag.arizona.edu/azmet/raw2003.htm. Note that the soil temperature
  # depths change between the 1987-2002 and 2003-present periods. We use the
  # depths from the latter to name these columns instead of generating new
  # columns for the different depths between the two periods. As we do not
  # anticipate using soil temperature data, this is of no consequence. However,
  # this code will need to be changed in order to address this issue if soil
  # temperature data becomes of interest.

  col_names_pre <- c(
    "obs_year",
    "obs_doy",
    "station_number",
    "obs_dyly_temp_air_max",
    "obs_dyly_temp_air_min",
    "obs_dyly_temp_air_mean",
    "obs_dyly_relative_humidity_max",
    "obs_dyly_relative_humidity_min",
    "obs_dyly_relative_humidity_mean",
    "obs_dyly_vpd_mean",
    "obs_dyly_sol_rad_total",
    "obs_dyly_precip_total",
    "temp_soil_shallow_max",
    "temp_soil_shallow_min",
    "temp_soil_shallow_mean",
    "temp_soil_deep_max",
    "temp_soil_deep_min",
    "temp_soil_deep_mean",
    "obs_dyly_wind_spd_mean",
    "obs_dyly_wind_vector_magnitude",
    "obs_dyly_wind_vector_dir",
    "obs_dyly_wind_vector_dir_stand_dev",
    "obs_dyly_wind_spd_max",
    "obs_dyly_derived_eto_azmet", # Derived: reference ETo
    "heat_units" # Derived: heat units (30/12.8C) (not in modern database)
  )

  col_names_post <- c(
    "obs_year",
    "obs_doy",
    "station_number",
    "obs_dyly_temp_air_max",
    "obs_dyly_temp_air_min",
    "obs_dyly_temp_air_mean",
    "obs_dyly_relative_humidity_max",
    "obs_dyly_relative_humidity_min",
    "obs_dyly_relative_humidity_mean",
    "obs_dyly_vpd_mean",
    "obs_dyly_sol_rad_total",
    "obs_dyly_precip_total",
    "obs_dyly_temp_soil_10cm_max", #4in
    "obs_dyly_temp_soil_10cm_min", #4in
    "obs_dyly_temp_soil_10cm_mean", #4in
    "obs_dyly_temp_soil_50cm_max", #20in
    "obs_dyly_temp_soil_50cm_min", #20in
    "obs_dyly_temp_soil_50cm_mean", #20in
    "obs_dyly_wind_spd_mean",
    "obs_dyly_wind_vector_magnitude",
    "obs_dyly_wind_vector_dir",
    "obs_dyly_wind_vector_dir_stand_dev",
    "obs_dyly_wind_spd_max",
    "heat_units", # Derived: heat units (30/12.8C) (not in modern database)
    "obs_dyly_derived_eto_azmet", # Derived: reference ETo original
    "obs_dyly_derived_eto_pen_mon", #Derived: reference ETo Penman-Monteith method
    "obs_dyly_actual_vp_mean",
    "obs_dyly_derived_dwpt_mean" #Derived: dewpoint, daily mean
  )

  # Set the string elements that together will build the full URL where
  # individual AZMET station data reside. Note that daily station data are
  # available by individual years.

  # Extract the row of information (station name, station number, start year,
  # and end year) tied to the selected AZMET station
  stn_info <- subset(x = stn_list, subset = stn == stn_name)

  # Set the station number based on the information extracted from 'stn_list' in
  # the previous command. The station number will need to be converted to a
  # character string in order to be put together with the other full URL string
  # elements. Also, if the station number is less than 10, the station number
  # character string will need to have a '0' preceeding it, in order to match
  # the AZMET daily data file name format.
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
  suffix <- "rd.txt"

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
  # DOWNLOAD DATA --------------------

  # Recall that AZMET data are provided year-by-year. We will need to
  # iteratively download the annual files.

  # We will treat the 1987-2002 and 2003-present periods differently.

  # If in the 1987-2002 period, switch the last two columns. These
  # changes are described at http://ag.arizona.edu/azmet/raw2003.htm.
  data_pre_2002 <- read_csv(
    urls_pre_2002,
    col_names = col_names_pre,
    col_types = cols(
      obs_year = col_integer(),
      obs_doy = col_integer()
    )
  )

  # Years prior to 2000 are to be two-digit values instead of four-digit
  # values. Overwrite the first column for all years with four-digit values.
  data_pre_2002 <- data_pre_2002 |>
    mutate(obs_year = ifelse(obs_year < 2000, obs_year + 1900L, obs_year))
  # Soil temp depths changed in 1999, from 2" and 4" to 4" and 20", respectively.
  data_pre_2002 <- data_pre_2002 |>
    mutate(
      obs_dyly_temp_soil_10cm_max = dplyr::if_else(
        obs_year < 1999,
        temp_soil_deep_max,
        temp_soil_shallow_max
      ),
      obs_dyly_temp_soil_10cm_min = dplyr::if_else(
        obs_year < 1999,
        temp_soil_deep_min,
        temp_soil_shallow_min
      ),
      obs_dyly_temp_soil_10cm_mean = dplyr::if_else(
        obs_year < 1999,
        temp_soil_deep_mean,
        temp_soil_shallow_mean
      ),
      obs_dyly_temp_soil_50cm_max = dplyr::if_else(
        obs_year < 1999,
        NA,
        temp_soil_deep_max
      ),
      obs_dyly_temp_soil_50cm_min = dplyr::if_else(
        obs_year < 1999,
        NA,
        temp_soil_deep_min
      ),
      obs_dyly_temp_soil_50cm_mean = dplyr::if_else(
        obs_year < 1999,
        NA,
        temp_soil_deep_mean
      )
    ) |>
    select(-starts_with("temp_soil_"))

  data_post_2002 <- read_csv(
    urls_post_2002,
    col_names = col_names_post,
    col_types = cols(
      obs_year = col_integer(),
      obs_doy = col_integer()
    )
  )

  # Concatenate the data in the row dimension as it is downloaded year-by-year
  stn_data <- bind_rows(data_pre_2002, data_post_2002)

  # FORMAT DATA --------------------

  # Populate new 'date', columns
  stn_data <- stn_data |>
    mutate(
      obs_datetime = as.Date(
        paste(stn_data$obs_year, stn_data$obs_doy),
        format = "%Y %j"
      )
    )

  # Based on previous work with AZMET data, there are several known formatting
  # bugs in the original / downloaded data files. We will address these
  # individually.

  # An odd character (".") appears at the end of some data files for some years
  # and some stations. In the R dataframe, this results in a row of NAs. Find
  # and remove these rows.
  # stn_data <- stn_data[rowSums(is.na(stn_data)) != ncol(stn_data), ]
  stn_data <- stn_data |> dplyr::filter(!is.na(station_number)) #TODO: might not be an issue

  # Replace 'nodata' values in the downloaded AZMET data with 'NA'. Values for
  # 'nodata' in AZMET data are designated as '999'. However, other similar
  # values also appear (e.g., 999.9 and 9999).
  stn_data <- stn_data |>
    mutate(across(
      where(is.numeric),
      \(x) ifelse(x %in% c(999, 999.9, 9999), NA, x)
    ))
  # stn_data[stn_data == 999] <- NA
  # stn_data[stn_data == 999.9] <- NA
  # stn_data[stn_data == 9999] <- NA

  # Find and remove duplicate row entries
  stn_data <- distinct(stn_data)

  # ADDRESS MISSING DAILY ENTRIES --------------------
  # This should correctly account for leap years
  stn_data <- stn_data |>
    tidyr::complete(
      obs_datetime = seq(
        lubridate::floor_date(min(obs_datetime, na.rm = TRUE), unit = "year"),
        lubridate::ceiling_date(max(obs_datetime, na.rm = TRUE), unit = "year"),
        "day"
      )
    )

  # Fill in values for year, and day-of-year for any date entries
  # that may be missing in the downloaded original data
  stn_data <- stn_data |>
    dplyr::mutate(
      obs_year = lubridate::year(obs_datetime),
      obs_doy = lubridate::yday(obs_datetime)
    )

  # Populate station ID in the format of "az01"
  station_number <- formatC(stn_info$stn_no[1], flag = 0, width = 2)
  station_id <- paste0("az", station_number)
  stn_data <- stn_data |>
    dplyr::mutate(
      station_number = station_number,
      station_id = station_id
    )

  # Populate defaults for some missing/empty columns
  stn_data <- stn_data |>
    dplyr::mutate(
      obs_hour = 0,
      obs_seconds = 0,
      obs_version = 1,
      obs_creation_reason = "legacy data transcription",
      obs_needs_review = 0,
      obs_prg_code = 0428, #"program code"—used to be size of program running on data logger, now just a 4 digit code.
      obs_dyly_bat_volt_max = NA_character_,
      obs_dyly_bat_volt_min = NA_character_,
      obs_dyly_bat_volt_mean = NA_character_,
      obs_dyly_actual_vp_max = NA_character_,
      obs_dyly_actual_vp_min = NA_character_
    )

  # TODO convert NAs to appropriate values using config file Matt shared.

  stn_data <- stn_data |>
    dplyr::select(
      station_id,
      station_number,
      obs_year,
      obs_doy,
      obs_datetime,
      obs_hour,
      obs_seconds,
      obs_version,
      # obs_creation_timestamp, #omit so it is created automatically on ingest
      obs_creation_reason,
      obs_needs_review,
      obs_prg_code,
      obs_dyly_temp_air_max,
      obs_dyly_temp_air_min,
      obs_dyly_temp_air_mean,
      obs_dyly_relative_humidity_max,
      obs_dyly_relative_humidity_min,
      obs_dyly_relative_humidity_mean,
      obs_dyly_vpd_mean,
      obs_dyly_sol_rad_total,
      obs_dyly_precip_total,
      obs_dyly_temp_soil_10cm_max,
      obs_dyly_temp_soil_10cm_min,
      obs_dyly_temp_soil_10cm_mean,
      obs_dyly_temp_soil_50cm_max,
      obs_dyly_temp_soil_50cm_min,
      obs_dyly_temp_soil_50cm_mean,
      obs_dyly_wind_spd_mean,
      obs_dyly_wind_vector_magnitude,
      obs_dyly_wind_vector_dir,
      obs_dyly_wind_vector_dir_stand_dev,
      obs_dyly_wind_spd_max,
      obs_dyly_bat_volt_max,
      obs_dyly_bat_volt_min,
      obs_dyly_bat_volt_mean,
      obs_dyly_actual_vp_max,
      obs_dyly_actual_vp_min,
      obs_dyly_actual_vp_mean
    )
  #TODO: create derived table and return a list of the two tables

  # RETURN DATA AND CLOSE FUNCTION --------------------
  return(stn_data)
}
