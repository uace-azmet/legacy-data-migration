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

# Helpers to deal with AZMET database using 2400 and 23:59:059 for midnight
# instead of ISO standard 00:00:00 like R.

# midnight <- ymd_hms("2024-12-31 24:00:00")

use_24_datetime <- function(x) {
  if_else(
    strftime(x, "%T", tz = tz(x)) == "00:00:00",
    glue::glue("{strftime(x - days(1), tz = tz(x), format = '%F')} 23:59:59"),
    strftime(x, tz = tz(x), format = '%F %T')
  )
}
# use_24_datetime(midnight) == "2024-12-31 23:59:59"
# use_24_datetime(ymd_hms("2024-04-28 01:00:00")) == "2024-04-28 01:00:00"

use_24_yday <- function(x) {
  if_else(
    strftime(x, "%T", tz = tz(x)) == "00:00:00",
    strftime(x - lubridate::days(1), "%j", tz = tz(x)), #deals with leap years and returns either 365 or 366
    strftime(x, "%j", tz = tz(x))
  )
}
# use_24_yday(midnight) != yday(midnight)
# use_24_yday(ymd_hms("2024-04-28 24:00:00")) == yday(ymd("2024-04-28"))

use_24_hour <- function(x) {
  if_else(
    strftime(x, "%T", tz = tz(x)) == "00:00:00",
    "2400",
    strftime(x, "%H00", tz = tz(x))
  )
}
# use_24_hour(midnight) == "2400"
# use_24_hour(ymd_hms("2024-04-28 02:00:00")) == "0200"

use_24_year <- function(x) {
  if_else(
    strftime(x, tz = tz(x), format = "%m-%d %T") == "01-01 00:00:00",
    strftime(x - lubridate::days(1), "%Y", tz = tz(x)),
    strftime(x, "%Y", tz = tz(x))
  )
}
# use_24_year(midnight) != year(midnight)
# use_24_year(midnight) == year(midnight - days(1))
