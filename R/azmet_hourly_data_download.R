# FUNCTION FOR DOWNLOADING AND FORMATTING HOURLY AZMET DATA

# Authors:
# Jeremy Weiss, Climate and Geospatial Extension Scientist
# School of Natural Resources and the Environment
# University of Arizona
# 520-626-8063, jlweiss@email.arizona.edu
#
# Eric R. Scott
# Communications and Cyber Technologies
# University of Arizona
# ORCID: 0000-0002-7430-7879

# This function downloads hourly AZMET data for an individual station, formats
# data into a dataframe, checks for missing or duplicate dates or other
# oddities, and writes the station data dataframe to the current environment

azmet_hourly_data_download <- function(stn_list, stn_name) {
  # SETUP --------------------

  # AZMET data format changes between the periods 1987-2002 and 2003-present, as
  # the number of variables measured / reported in the data file is different.

  # Set column name string based on the 2003-present period. This list can be
  # found at http://ag.arizona.edu/azmet/raw2003.htm. Note that the soil
  # temperature depths change between the 1987-2002 and 2003-present periods.
  # Heat Units from the 1987-2002 are omitted from the returned dataframe.
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
      "rETo", #reference ETo
      "heat_units"
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
      "rETo", #reference ETo
      "obs_hrly_actual_vp",
      "DP" #dewpoint, hourly average
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
  suffix <- "rh.txt"

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
  # combine the annual files.
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
      obs_hrly_temp_soil_10cm = dplyr::if_else(
        obs_year < 1999,
        temp_soil_deep,
        temp_soil_shallow
      ),
      obs_hrly_temp_soil_50cm = dplyr::if_else(
        obs_year < 1999,
        NA,
        temp_soil_deep
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

  # Populate new `obs_datetime` column
  stn_data <- stn_data |>
    mutate(
      obs_datetime = as.Date(
        paste(stn_data$obs_year, stn_data$obs_doy),
        format = "%Y %j"
      ) +
        hours(obs_hour),
      .before = 1
    )

  # Based on previous work with AZMET data, there are several known formatting
  # bugs in the original / downloaded data files. We will address these
  # individually.

  # An odd character (".") appears at the end of some data files for some years
  # and some stations. In the R dataframe, this results in a row of NAs. Find
  # and remove these rows.
  # stn_data <- stn_data[rowSums(is.na(stn_data)) != ncol(stn_data), ]
  stn_data <- stn_data |> dplyr::filter(!is.na(obs_year)) #TODO: might not be an issue

  # Replace 'nodata' values in the downloaded AZMET data with 'NA'. Values for
  # 'nodata' in AZMET data are designated as '999'. However, other similar
  # values also appear (e.g., 999.9 and 9999).
  stn_data <- stn_data |>
    mutate(across(
      where(is.numeric),
      \(x) ifelse(x %in% c(999, 999.9, 9999), NA, x)
    ))

  # Find and remove duplicate row entries
  stn_data <- distinct(stn_data)

  # ADDRESS MISSING HOURLY ENTRIES --------------------

  # This should correctly account for leap years
  stn_data <- stn_data |>
    tidyr::complete(
      obs_datetime = seq(
        lubridate::floor_date(min(obs_datetime, na.rm = TRUE), unit = "year"),
        lubridate::ceiling_date(max(obs_datetime, na.rm = TRUE), unit = "year"),
        "hour"
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
  station_id <- formatC(stn_info$stn_no[1], flag = 0, width = 2)
  station_id <- paste0("az", station_id)
  stn_data <- stn_data |>
    mutate(station_id = station_id)

  # RETURN DATA AND CLOSE FUNCTION --------------------

  #select columns according to database schema
  stn_data <- stn_data |>
    select(
      station_id,
      # station_number, #TODO: not sure what this should look like
      obs_year,
      obs_doy,
      obs_hour,
      # TODO: not sure about these
      # obs_seconds,
      # obs_version,
      # obs_creation_timestamp,
      # obs_creation_reason,
      # obs_needs_review,
      # obs_prg_code,
      obs_hrly_temp_air,
      obs_hrly_relative_humidity,
      obs_hrly_vpd,
      obs_hrly_sol_rad_total,
      obs_hrly_precip_total,
      obs_hrly_temp_soil_10cm,
      obs_hrly_temp_soil_50cm,
      obs_hrly_wind_spd,
      obs_hrly_wind_vector_magnitude,
      obs_hrly_wind_vector_dir,
      obs_hrly_wind_vector_dir_stand_dev,
      obs_hrly_wind_spd_max,
      obs_hrly_actual_vp,
      # obs_hrly_bat_volt #TODO: some discussion about possibly being able to find this
    )

  return(stn_data)
}
