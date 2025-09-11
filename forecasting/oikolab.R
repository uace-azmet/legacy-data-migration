#use Oikolab api
library(httr2)
library(azmetr)
library(purrr)
library(dplyr)
library(sf)

#need to sign up for an account at oikolab.com and get an API key from
#https://www.oikolab.com/subscription/. Then, store that key in .Renviron as
#OIKOLAB_KEY.

# API documentation: https://docs.oikolab.com/references/

# Build the request
req <- request('https://api.oikolab.com/weather') |>
  req_headers_redacted('api-key' = Sys.getenv("OIKOLAB_KEY")) |>
  # req_oauth() |>
  req_url_query(
    model = "ifs-open", #the only publicly-available forecast product from ECMWF
    run = "00z",
    param = c("temperature", "relative_humidity"),
    lat = station_info$latitude,
    lon = station_info$longitude,
    location_id = station_info$meta_station_id,
    freq = "H",
    # get 5 days out
    start = Sys.Date(),
    end = Sys.Date() + 5,
    .multi = "explode"
  )

resp <- req_perform(req)
resp_data <- resp |> resp_body_json() |> pluck("data") |> jsonlite::fromJSON()
df <- resp_data$data
colnames(df) <- resp_data$columns
df <- df |>
  as_tibble() |>
  mutate(
    datetime = as.POSIXct(resp_data$index),
    .before = 1
  ) |>
  mutate(across(c(contains("temperature"), contains("humidity")), as.numeric))
df

library(ggplot2)

ggplot(
  df,
  aes(x = datetime, y = `relative_humidity (0-1)`, color = `location_id (id)`)
) +
  geom_line()
