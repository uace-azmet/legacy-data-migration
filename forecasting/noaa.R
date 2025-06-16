library(httr2)
library(purrr)

lat <- 38.8894
lon <- -77.0352

req_base <- request("https://api.weather.gov") |>
  req_user_agent("AZMet (https://azmet.arizona.edu/)")

req_meta <- req_base |>
  req_url_path_append("points", glue::glue("{lat},{lon}"))

resp_meta <- req_perform(req_meta)
forecast_url <- resp_body_json(resp_meta)$properties$forecast
req_forecast <- request(forecast_url) |>
  req_cache(path = "noaa_cache") |>
  req_user_agent("AZMet (https://azmet.arizona.edu/)")
resp_forecast <- req_perform(req_forecast)
resp_body_json(resp_forecast)$properties$periods |>
  map(\(x) {
    tibble(
      temp_f = x$temperature,
      time_start = lubridate::ymd_hms(x$startTime),
      time_end = lubridate::ymd_hms(x$endTime)
    )
  }) |>
  list_rbind()
