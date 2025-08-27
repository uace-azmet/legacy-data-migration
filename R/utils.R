#unit conversions

c_to_f <- function(x) {
  x * (9 / 5) + 32
}

mjm2_to_ly <- function(x) {
  x * 23.9005736137667
}

mm_to_in <- function(x) {
  x * 1 / 25.4
}

mps_to_mph <- function(x) {
  x * 2.2369362920544
}

# Helpers to deal with AZMET database using 24:00:00 for midnight instead of
# 00:00:00 like R.

# midnight <- ymd_hms("2024-12-31 24:00:00")

use_24_datetime <- function(x) {
  if_else(
    strftime(x, "%T", tz = tz(x)) == "00:00:00",
    glue::glue("{strftime(x - days(1), tz = tz(x), format = '%F')} 23:59:59"),
    glue::glue("{strftime(x, tz = tz(x), format = '%F %T')}")
  )
}
# use_24_datetime(midnight) == "2024-12-31 23:59:59"
# use_24_datetime(ymd_hms("2024-04-28 01:00:00")) == "2024-04-28 01:00:00"

use_24_yday <- function(x) {
  if_else(
    strftime(x, "%T", tz = tz(x)) == "00:00:00",
    lubridate::yday(x - lubridate::days(1)), #deals with leap years and returns either 365 or 366
    lubridate::yday(x)
  )
}
# use_24_yday(midnight) != yday(midnight)
# use_24_yday(ymd_hms("2024-04-28 24:00:00")) == yday(ymd("2024-04-28"))

use_24_hour <- function(x) {
  if_else(strftime(x, "%T", tz = tz(x)) == "00:00:00", 24L, lubridate::hour(x))
}
# use_24_hour(midnight) == 24
# use_24_hour(ymd_hms("2024-04-28 11:00:00")) == 11

use_24_year <- function(x) {
  if_else(
    strftime(x, tz = tz(x), format = "%m-%d %T") == "01-01 00:00:00",
    lubridate::year(x - lubridate::days(1)),
    lubridate::year(x)
  )
}
# use_24_year(midnight) != year(midnight)
# use_24_year(midnight) == year(midnight - days(1))
