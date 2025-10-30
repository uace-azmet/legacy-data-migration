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

#' @param stn_list a data frame with columns `stn` (station name), `stn_no`, `start_yr`, and `end_yr`
#' @param stn_name character; station name
#' @param years integer; optional vector of min and max years
azmet_daily_data_download <- function(stn_list, stn_name, years = NULL) {
  # SETUP --------------------

  # AZMET data format changes between the periods 1987-2002 and 2003-present, as
  # the number of variables measured / reported and their order in the data file
  # are slightly different. We will set up a column name string that matches the
  # variables and variable order of the latter period.

  # Set column name string for the 2003-present period. This list can be found
  # at http://ag.arizona.edu/azmet/raw2003.htm. Note that the soil temperature
  # depths change in 1999.

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
  suffix <- "rd.txt"

  if (any(stn_yrs <= 2002)) {
    urls_pre_2002 <- paste0(
      baseurl,
      stn_no,
      substr(as.character(stn_yrs[stn_yrs <= 2002]), 3, 4),
      suffix
    )
  }

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

  # If in the 1987-2002 period, switch the last two columns. These changes are
  # described at http://ag.arizona.edu/azmet/raw2003.htm.
  if (any(stn_yrs <= 2002)) {
    data_pre_2002 <- read_csv(
      urls_pre_2002,
      col_names = col_names_pre,
      col_types = cols(
        obs_year = col_character(),
        obs_doy = col_character()
      ),
      id = "url",
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
  } else {
    #if there's no pre-2002 data
    data_pre_2002 <- tibble::tibble()
  }

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
    # Sometimes there is an odd end of line character that contaminates the year column
    mutate(across(c(obs_year, obs_doy), \(x) {
      str_remove(x, "\\u001a") |> parse_integer()
    }))

  # Concatenate the data in the row dimension as it is downloaded year-by-year
  obs_dyly <- bind_rows(data_pre_2002, data_post_2002)

  # FORMAT DATA --------------------
  # The year from the URL is more reliable than the one in the data, which
  # ocasionally is a different year
  # (https://github.com/uace-azmet/legacy-data-migration/issues/7)
  obs_dyly <- obs_dyly |>
    mutate(obs_year = as.integer(str_extract(url, "\\d{2}(?=rd.txt$)"))) |>
    mutate(
      obs_year = if_else(
        between(obs_year, 87, 99),
        obs_year + 1900L,
        obs_year + 2000L
      )
    ) |>
    select(-url)

  # Populate new 'date', columns
  obs_dyly <- obs_dyly |>
    mutate(
      obs_datetime = as.Date(
        paste(obs_dyly$obs_year, obs_dyly$obs_doy),
        format = "%Y %j"
      ),
      .before = obs_year
    )

  # Based on previous work with AZMET data, there are several known formatting
  # bugs in the original / downloaded data files. We will address these
  # individually.

  # Replace 'nodata' values in the downloaded AZMET data with 'NA'. Values for
  # 'nodata' in AZMET data are designated as '999'. However, other similar
  # values also appear (e.g., 999.9 and 9999).
  obs_dyly <- obs_dyly |>
    mutate(across(
      where(is.numeric),
      \(x) ifelse(abs(x) %in% c(999, 999.9, 9999), NA, x)
    ))

  # Find and remove duplicate row entries
  obs_dyly <- distinct(obs_dyly)

  # Remove rows that are all NAs (we'll add any necessary ones back later)
  # (https://github.com/uace-azmet/legacy-data-migration/issues/7)
  obs_dyly <- obs_dyly |>
    filter(!if_all(obs_dyly_temp_air_max:obs_dyly_derived_dwpt_mean, is.na))

  # Warn if there are more than one row per day
  obs_dyly_duplicated <- obs_dyly |>
    group_by(obs_year, obs_doy) |>
    filter(n() > 1) |>
    tidyr::nest() |>
    mutate(
      cols_diff = map_chr(data, \(df) {
        names(which(map_lgl(df, \(x) length(unique(x)) > 1))) |>
          paste0(collapse = ", ")
      }),
      .after = obs_doy
    ) |>
    tidyr::unnest(data)

  if (nrow(obs_dyly_duplicated > 0)) {
    cli::cli_warn(
      "{stn_name}: {nrow(count(obs_dyly_duplicated))} day{?s} {?has/have} multiple observations!"
    )
  }

  # ADDRESS MISSING DAILY ENTRIES --------------------
  # This should correctly account for leap years
  obs_dyly <- obs_dyly |>
    tidyr::complete(
      obs_datetime = seq(
        min(obs_datetime, na.rm = TRUE),
        max(obs_datetime, na.rm = TRUE),
        "day"
      )
    )

  # Fill in values for year, and day-of-year for any date entries
  # that may be missing in the downloaded original data
  obs_dyly <- obs_dyly |>
    dplyr::mutate(
      obs_year = strftime(obs_datetime, "%Y", tz = tz(obs_datetime)),
      obs_doy = strftime(obs_datetime, "%j", tz = tz(obs_datetime))
    )

  # Populate station ID in the format of "az01"
  station_number <- formatC(stn_info$stn_no[1], flag = 0, width = 2)
  station_id <- paste0("az", station_number)

  obs_dyly <- obs_dyly |>
    dplyr::mutate(
      station_number = station_number,
      station_id = station_id
    )

  # Populate defaults for some missing/empty columns
  obs_dyly <- obs_dyly |>
    dplyr::mutate(
      obs_hour = "0000",
      obs_seconds = 0,
      obs_version = 1,
      obs_creation_reason = "legacy data transcription",
      obs_needs_review = 0,
      obs_prg_code = "0428", #"program code"—used to be size of program running on data logger, now just a 4 digit code.
      obs_dyly_bat_volt_max = NA_real_,
      obs_dyly_bat_volt_min = NA_real_,
      obs_dyly_bat_volt_mean = NA_real_,
      obs_dyly_actual_vp_max = NA_real_,
      obs_dyly_actual_vp_min = NA_real_,
      obs_dyly_wind_2min_spd_mean = NA_real_,
      obs_dyly_wind_2min_spd_max = NA_real_,
      obs_dyly_wind_2min_timestamp = NA_real_,
      obs_dyly_wind_2min_vector_dir = NA_real_
    ) |>
    # basic range checks
    # TODO: Should these NOT be the 2min ones?
    dplyr::mutate(
      obs_dyly_wind_2min_spd_max = dplyr::if_else(
        !between(obs_dyly_wind_2min_spd_max, 0, 60),
        NA_real_,
        obs_dyly_wind_2min_spd_max
      ),
      obs_dyly_wind_2min_spd_mean = dplyr::if_else(
        !between(obs_dyly_wind_2min_spd_mean, 0, 50),
        NA_real_,
        obs_dyly_wind_2min_spd_mean
      ),
      obs_dyly_wind_2min_vector_dir = dplyr::if_else(
        !between(obs_dyly_wind_2min_vector_dir, 0, 360),
        NA_real_,
        obs_dyly_wind_2min_vector_dir
      )
    )

  # Create derived values table ------------
  obs_dyly_derived <- obs_dyly |>
    # do unit conversions
    # fmt: skip
    mutate(
      obs_dyly_derived_temp_air_maxF = c_to_f(obs_dyly_temp_air_max),
      obs_dyly_derived_temp_air_minF = c_to_f(obs_dyly_temp_air_min),
      obs_dyly_derived_temp_air_meanF = c_to_f(obs_dyly_temp_air_mean),
      obs_dyly_derived_sol_rad_total_ly = mjm2_to_ly(obs_dyly_sol_rad_total),
      obs_dyly_derived_precip_total_in = mm_to_in(obs_dyly_precip_total),
      obs_dyly_derived_temp_soil_10cm_maxF = c_to_f(obs_dyly_temp_soil_10cm_max),
      obs_dyly_derived_temp_soil_10cm_minF = c_to_f(obs_dyly_temp_soil_10cm_min),
      obs_dyly_derived_temp_soil_10cm_meanF = c_to_f(obs_dyly_temp_soil_10cm_mean),
      obs_dyly_derived_temp_soil_50cm_maxF = c_to_f(obs_dyly_temp_soil_50cm_max),
      obs_dyly_derived_temp_soil_50cm_minF = c_to_f(obs_dyly_temp_soil_50cm_min),
      obs_dyly_derived_temp_soil_50cm_meanF = c_to_f(obs_dyly_temp_soil_50cm_mean),
      obs_dyly_derived_wind_spd_mean_mph = mps_to_mph(obs_dyly_wind_spd_mean),
      obs_dyly_derived_wind_vector_magnitude_mph = mps_to_mph(obs_dyly_wind_vector_magnitude),
      obs_dyly_derived_wind_spd_max_mph = mps_to_mph(obs_dyly_wind_spd_max),
      obs_dyly_derived_dwpt_mean = obs_dyly_derived_dwpt_mean,
      obs_dyly_derived_dwpt_meanF = c_to_f(obs_dyly_derived_dwpt_mean),
      obs_dyly_derived_eto_azmet = obs_dyly_derived_eto_azmet,
      obs_dyly_derived_eto_azmet_in = mm_to_in(obs_dyly_derived_eto_azmet),
      obs_dyly_derived_eto_pen_mon = obs_dyly_derived_eto_pen_mon,
      obs_dyly_derived_eto_pen_mon_in = mm_to_in(obs_dyly_derived_eto_pen_mon),
      obs_dyly_derived_chill_hours_32F = NA_real_,
      obs_dyly_derived_chill_hours_45F = NA_real_,
      obs_dyly_derived_chill_hours_68F = NA_real_,
      obs_dyly_derived_chill_hours_0C = NA_real_,
      obs_dyly_derived_chill_hours_7C = NA_real_,
      obs_dyly_derived_chill_hours_20C = NA_real_,
      obs_dyly_derived_heat_units_7C = NA_real_,
      obs_dyly_derived_heat_units_10C = NA_real_,
      obs_dyly_derived_heat_units_13C = NA_real_,
      obs_dyly_derived_heat_units_3413C = NA_real_,
      obs_dyly_derived_heat_units_45F = NA_real_,
      obs_dyly_derived_heat_units_50F = NA_real_,
      obs_dyly_derived_heat_units_55F = NA_real_,
      obs_dyly_derived_heat_units_9455F = NA_real_,
      obs_dyly_derived_heatstress_cotton_meanC = NA_real_,
      obs_dyly_derived_heatstress_cotton_meanF = NA_real_,
      obs_dyly_derived_wind_2min_spd_mean_mph = NA_real_,
      obs_dyly_derived_wind_2min_spd_max_mph = NA_real_,
    ) |>
    select(
      station_id,
      obs_year,
      obs_doy,
      obs_datetime,
      obs_version,
      obs_creation_reason,
      starts_with("obs_dyly_derived_")
    ) |>
    #replace NAs and round
    dplyr::mutate(
      across(
        c(
          obs_dyly_derived_eto_pen_mon_in,
          obs_dyly_derived_precip_total_in,
          obs_dyly_derived_sol_rad_total_ly,
          obs_dyly_derived_eto_azmet_in
        ),
        \(x) {
          dplyr::if_else(
            is.na(x),
            "-999.00",
            as.character(round(x, digits = 2))
          )
        }
      ),
      across(
        c(
          starts_with("obs_dyly_derived_dwpt_"),
          obs_dyly_derived_eto_pen_mon,
          starts_with("obs_dyly_derived_heat_units_"),
          starts_with("obs_dyly_derived_temp_air_"),
          starts_with("obs_dyly_derived_temp_soil_"),
          starts_with("obs_dyly_derived_wind_"),
          starts_with("obs_dyly_derived_heatstress_cotton_"),
          obs_dyly_derived_eto_azmet,
          starts_with("obs_dyly_derived_wind_2min_spd_")
        ),
        \(x) {
          dplyr::if_else(
            is.na(x),
            "-9999.0",
            as.character(round(x, digits = 1))
          )
        }
      ),
      across(
        c(
          starts_with("obs_dyly_derived_chill_hours_")
        ),
        \(x) {
          dplyr::if_else(is.na(x), "-99999", as.character(round(x, digits = 0)))
        }
      )
    )

  obs_dyly <- obs_dyly |>
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
      obs_dyly_actual_vp_mean,
      obs_dyly_wind_2min_spd_mean,
      obs_dyly_wind_2min_spd_max,
      obs_dyly_wind_2min_timestamp,
      obs_dyly_wind_2min_vector_dir
    ) |>
    # replace NAs with correct values and round
    dplyr::mutate(
      dplyr::across(
        c(
          dplyr::starts_with("obs_dyly_actual_vp_"),
          dplyr::starts_with("obs_dyly_bat_volt_"),
          obs_dyly_sol_rad_total,
          obs_dyly_vpd_mean
        ),
        \(x) {
          dplyr::if_else(
            is.na(x),
            "-999.00",
            as.character(round(x, digits = 2))
          )
        }
      ),
      dplyr::across(
        c(
          obs_dyly_precip_total,
          dplyr::starts_with("obs_dyly_relative_humidity_"),
          dplyr::starts_with("obs_dyly_temp_air_"),
          dplyr::starts_with("obs_dyly_temp_soil_"),
          dplyr::starts_with("obs_dyly_wind_spd_"),
          obs_dyly_wind_vector_magnitude,
          dplyr::starts_with("obs_dyly_wind_2min_spd_")
        ),
        \(x) {
          dplyr::if_else(
            is.na(x),
            "-9999.0",
            as.character(round(x, digits = 1))
          )
        }
      ),
      dplyr::across(
        c(
          dplyr::starts_with("obs_dyly_wind_vector_dir"),
          obs_dyly_wind_2min_vector_dir,
          obs_dyly_wind_2min_timestamp
        ),
        \(x) {
          dplyr::if_else(is.na(x), "-99999", as.character(round(x, digits = 0)))
        }
      )
    )

  # RETURN DATA AND CLOSE FUNCTION --------------------
  return(list(
    obs_dyly = obs_dyly,
    obs_dyly_derived = obs_dyly_derived,
    obs_dyly_duplicated = obs_dyly_duplicated
  ))
}
