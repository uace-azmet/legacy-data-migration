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

azmet_hourly_data_download <- function(stn_list, stn_name, years = NULL) {
  # SETUP --------------------

  # AZMET data format changes between the periods 1987-2002 and 2003-present, as
  # the number of variables measured / reported in the data file is different.

  # Set column names separately for the pre-2003 and 2003-present periods. This
  # list can be found at https://cales.arizona.edu/azmet/az-docs.htm. Note that the
  # soil temperature depths change in 1999. Heat Units from the 1987-2002 are
  # omitted from the returned dataframe.
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

  # Set the string elements that together will build the full URL where
  # individual AZMET station data reside. Note that daily station data are
  # available by individual years.

  # Extract the row of information (station name, station number, start year,
  # and end year) tied to the selected AZMET station
  stn_info <- subset(x = stn_list, subset = stn == stn_name)

  # optionally filter by years
  if (!is.null(years)) {
    stn_info <- stn_info |>
      mutate(
        start_yr = pmax(min(years), start_yr),
        end_yr = pmin(max(years), end_yr)
      )
  }

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
  if (any(stn_yrs <= 2002)) {
    urls_pre_2002 <- paste0(
      baseurl,
      stn_no,
      substr(as.character(stn_yrs[stn_yrs <= 2002]), 3, 4),
      suffix
    )
  }
  if (any(stn_yrs > 2002)) {
    urls_post_2002 <- paste0(
      baseurl,
      stn_no,
      substr(as.character(stn_yrs[stn_yrs > 2002]), 3, 4),
      suffix
    )
  }

  # DOWNLOAD DATA --------------------

  # Recall that AZMET data are provided year-by-year. We will need to
  # combine the annual files.
  if (any(stn_yrs <= 2002)) {
    data_pre_2002 <- read_delim(
      urls_pre_2002,
      delim = ",",
      escape_backslash = TRUE,
      col_names = col_names_pre,
      col_types = cols(
        obs_year = col_character(),
        obs_doy = col_character()
      ),
      id = "url", #save the url
      trim_ws = TRUE
    ) |>
      # Sometimes there is an odd end of line character that contaminates the year column
      mutate(across(c(obs_year, obs_doy), \(x) {
        str_remove(x, "\\u001a") |> parse_integer()
      }))
    # Years prior to 2000 are to be two-digit values instead of four-digit
    # values. Overwrite the first column for all years with four-digit values.
    data_pre_2002 <- data_pre_2002 |>
      mutate(obs_year = ifelse(obs_year < 2000, obs_year + 1900L, obs_year))

    # Soil temp depths changed in 1999, from 2" and 4" to 4" and 20",
    # respectively.
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
  } else {
    data_pre_2002 <- tibble::tibble()
  }

  if (any(stn_yrs > 2002)) {
    data_post_2002 <- read_csv(
      urls_post_2002,
      col_names = col_names_post,
      col_types = cols(
        obs_year = col_character(),
        obs_doy = col_character()
      ),
      id = "url",
      trim_ws = TRUE
    ) |>
      mutate(across(c(obs_year, obs_doy), \(x) {
        str_remove(x, "\\u001a") |> parse_integer()
      }))
  } else {
    data_post_2002 <- tibble::tibble()
  }
  # Combine pre- and post-2003
  obs_hrly <- bind_rows(data_pre_2002, data_post_2002)

  # FORMAT DATA --------------------

  # The year from the URL is more reliable than the one in the data, which
  # ocasionally is a different year
  # (https://github.com/uace-azmet/legacy-data-migration/issues/7)
  obs_hrly <- obs_hrly |>
    mutate(obs_year = as.integer(str_extract(url, "\\d{2}(?=rh.txt$)"))) |>
    mutate(
      obs_year = if_else(
        between(obs_year, 87, 99),
        obs_year + 1900L,
        obs_year + 2000L
      )
    ) |>
    select(-url)

  # Populate new`obs_datetime` column
  obs_hrly <- obs_hrly |>
    mutate(
      obs_datetime = as.Date(
        paste(obs_hrly$obs_year, obs_hrly$obs_doy),
        format = "%Y %j"
      ) +
        lubridate::hours(obs_hour),
      .before = obs_year
    )
  # Note that AZMET uses 24:00:00 for midnight and R automatically converts that
  # to 00:00:00 of the next day.  This will get corrected later.

  # Based on previous work with AZMET data, there are several known formatting
  # bugs in the original / downloaded data files. We will address these
  # individually.

  # Replace 'nodata' values in the downloaded AZMET data with 'NA'. Values for
  # 'nodata' in AZMET data are designated as '999'. However, other similar
  # values also appear (e.g., 999.9 and 9999).
  obs_hrly <- obs_hrly |>
    mutate(across(
      where(is.numeric),
      \(x) if_else(abs(x) %in% c(999, 999.9, 9999), NA_real_, x)
    ))

  # Populate station ID in the format of "az01"
  station_number <- formatC(stn_info$stn_no[1], flag = 0, width = 2)
  station_id <- paste0("az", station_number)
  obs_hrly <- obs_hrly |>
    mutate(station_id = station_id, station_number = station_number)

  # Find and remove duplicate row entries
  obs_hrly <- distinct(obs_hrly)

  # Remove rows that are all NAs (we'll add any necessary ones back later)
  # (https://github.com/uace-azmet/legacy-data-migration/issues/7)
  obs_hrly <- obs_hrly |>
    filter(!if_all(any_of(unique(c(col_names_pre, col_names_post))), is.na))

  # Warn if there are more than one row per hour
  obs_hrly_duplicated <- obs_hrly |>
    group_by(obs_year, obs_doy, obs_hour) |>
    filter(n() > 1) |>
    tidyr::nest() |>
    mutate(
      cols_diff = map_chr(data, \(df) {
        names(which(map_lgl(df, \(x) length(unique(x)) > 1))) |>
          paste0(collapse = ", ")
      }),
      .after = obs_hour
    ) |>
    tidyr::unnest(data)

  if (nrow(obs_hrly_duplicated > 0)) {
    cli::cli_warn(
      "{stn_name}: {nrow(count(obs_hrly_duplicated))} hour{?s} {?has/have} multiple observations!"
    )
  }

  # ADDRESS MISSING HOURLY ENTRIES --------------------

  # This should correctly account for leap years
  obs_hrly <- obs_hrly |>
    tidyr::complete(
      obs_datetime = seq(
        lubridate::floor_date(min(obs_datetime, na.rm = TRUE), unit = "day") +
          hours(1), # days always start at 01:00:00 because of how midnight is handled with AZMET
        lubridate::ceiling_date(max(obs_datetime, na.rm = TRUE), unit = "day"),
        "hour"
      )
    )

  # Fill in values for year, and day-of-year for any date entries that may be
  # missing in the downloaded original data, and correct for the fact that AZMET
  # uses 24:00:00 for midnight.
  obs_hrly <- obs_hrly |>
    dplyr::mutate(
      obs_year = use_24_year(obs_datetime),
      obs_doy = use_24_yday(obs_datetime),
      obs_hour = use_24_hour(obs_datetime)
    ) |>
    dplyr::mutate(
      #converts to character, but that's ok because we're done with it now
      obs_datetime = use_24_datetime(obs_datetime)
    )

  # Populate defaults for some missing/empty columns
  obs_hrly <- obs_hrly |>
    mutate(
      obs_seconds = 0,
      obs_version = 1,
      obs_creation_reason = "legacy data transcription",
      obs_needs_review = 0,
      obs_prg_code = "0428", #"program code"—used to be size of program running on data logger, now just a 4 digit code.
      obs_hrly_wind_2min_vector_dir = NA_real_,
      obs_hrly_wind_2min_spd_max = NA_real_,
      obs_hrly_wind_2min_spd_mean = NA_real_,
      obs_hrly_wind_2min_timestamp = NA_real_,
      obs_hrly_bat_volt = NA_real_
    )

  # Create derived table -----------
  obs_hrly_derived <- obs_hrly |>
    #do unit conversions
    # fmt: skip
    mutate(
      obs_hrly_derived_temp_airF = c_to_f(obs_hrly_temp_air),
      obs_hrly_sol_rad_total_ly = mjm2_to_ly(obs_hrly_sol_rad_total),
      obs_hrly_derived_precip_total_in = mm_to_in(obs_hrly_precip_total),
      obs_hrly_derived_temp_soil_10cmF = c_to_f(obs_hrly_temp_soil_10cm),
      obs_hrly_derived_temp_soil_50cmF = c_to_f(obs_hrly_temp_soil_50cm),
      obs_hrly_derived_wind_spd_mph = mps_to_mph(obs_hrly_wind_spd),
      obs_hrly_wind_vector_magnitude_mph = mps_to_mph(obs_hrly_wind_vector_magnitude),
      obs_hrly_derived_wind_spd_max_mph = mps_to_mph(obs_hrly_wind_spd_max),
      obs_hrly_derived_wind_2min_spd_max_mph = NA_real_,
      obs_hrly_derived_wind_2min_spd_mean_mph = NA_real_,
      obs_hrly_derived_dwpt = obs_hrly_derived_dwpt,
      obs_hrly_derived_dwptF = c_to_f(obs_hrly_derived_dwpt),
      obs_hrly_derived_eto_azmet = obs_hrly_derived_eto_azmet,
      obs_hrly_derived_eto_azmet_in = mm_to_in(obs_hrly_derived_eto_azmet),
      obs_hrly_derived_heatstress_cottonC = NA_real_,
      obs_hrly_derived_heatstress_cottonF = NA_real_
    ) |>
    select(
      station_id,
      obs_year,
      obs_doy,
      obs_hour,
      obs_seconds,
      obs_datetime,
      obs_version,
      # obs_creation_timestamp, #omit so it will be populated automatically upon ingest
      obs_creation_reason,
      obs_hrly_derived_temp_airF,
      obs_hrly_sol_rad_total_ly,
      obs_hrly_derived_precip_total_in,
      obs_hrly_derived_temp_soil_10cmF,
      obs_hrly_derived_temp_soil_50cmF,
      obs_hrly_derived_wind_spd_mph,
      obs_hrly_wind_vector_magnitude_mph,
      obs_hrly_derived_wind_spd_max_mph,
      obs_hrly_derived_wind_2min_spd_max_mph,
      obs_hrly_derived_wind_2min_spd_mean_mph,
      obs_hrly_derived_dwpt,
      obs_hrly_derived_dwptF,
      obs_hrly_derived_eto_azmet,
      obs_hrly_derived_eto_azmet_in,
      obs_hrly_derived_heatstress_cottonC,
      obs_hrly_derived_heatstress_cottonF
    ) |>
    # Convert NAs
    mutate(
      across(
        c(
          obs_hrly_derived_eto_azmet_in,
          obs_hrly_derived_precip_total_in,
          obs_hrly_sol_rad_total_ly
        ),
        \(x) {
          if_else(is.na(x), "-999.00", as.character(round(x, digits = 2)))
        }
      ),
      across(
        c(
          obs_hrly_derived_eto_azmet,
          starts_with("obs_hrly_derived_dwpt"),
          starts_with("obs_hrly_derived_heatstress_cotton"),
          starts_with("obs_hrly_derived_temp_"),
          starts_with("obs_hrly_derived_wind_spd_"),
          starts_with("obs_hrly_derived_wind_2min_spd_")
        ),
        \(x) {
          if_else(is.na(x), "-9999.0", as.character(round(x, digits = 1)))
        }
      )
    )

  #select columns according to database schema
  obs_hrly <- obs_hrly |>
    select(
      station_id,
      station_number,
      obs_datetime,
      obs_year,
      obs_doy,
      obs_hour,
      obs_seconds,
      obs_version,
      # obs_creation_timestamp, #omit so it will be populated automatically upon ingest
      obs_creation_reason,
      obs_needs_review,
      obs_prg_code,
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
      obs_hrly_wind_2min_vector_dir,
      obs_hrly_wind_2min_spd_max,
      obs_hrly_wind_2min_spd_mean,
      obs_hrly_wind_2min_timestamp,
      obs_hrly_actual_vp,
      obs_hrly_bat_volt
    ) |>
    #convert NAs
    mutate(
      across(
        c(
          obs_hrly_actual_vp,
          obs_hrly_bat_volt,
          obs_hrly_sol_rad_total,
          obs_hrly_vpd
        ),
        \(x) if_else(is.na(x), "-999.00", as.character(round(x, digits = 2)))
      ),
      across(
        c(
          obs_hrly_precip_total,
          starts_with("obs_hrly_temp_"),
          starts_with("obs_hrly_wind_spd"),
          starts_with("obs_hrly_wind_vector_magnitude"),
          starts_with("obs_hrly_wind_2min_spd_"),
        ),
        \(x) if_else(is.na(x), "-9999.0", as.character(round(x, digits = 1)))
      ),
      across(
        c(
          obs_hrly_relative_humidity,
          starts_with("obs_hrly_wind_vector_dir"),
          obs_hrly_wind_2min_vector_dir,
          obs_hrly_wind_2min_timestamp
        ),
        \(x) if_else(is.na(x), "-99999", as.character(round(x, digits = 0)))
      )
    )

  return(list(
    obs_hrly = obs_hrly,
    obs_hrly_derived = obs_hrly_derived,
    obs_hrly_duplicated = obs_hrly_duplicated
  ))
}
