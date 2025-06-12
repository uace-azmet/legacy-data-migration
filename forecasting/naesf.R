library(glue)
library(fs)
library(sf)
sf_use_s2(use_s2 = TRUE)
library(httr2)
library(azmetr) #for station_info
library(terra)
library(exactextractr) #https://github.com/isciences/exactextractr
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)


cycles <- c("00", "12")
cycle <- cycles[1]
stats <- c("avg", "spr", "mode", "10pt", "50pt", "90pt")
#hours available for this model
hours <- c(seq(3, 192, by = 3), seq(192, 384, by = 6)) |>
  unique() |>
  formatC(width = 3, flag = 0)

# buffers and bbox
station_sf <- station_info |>
  st_as_sf(coords = c("longitude", "latitude")) |>
  st_set_crs(4326)

# adding a buffer does two things:
# 1) ensures that our stations get included in the bbox when they are on the border
# 2) optionally lets us extract means for some radius around the weather station rather than just the point its on
station_buffer_sf <- station_sf |>
  st_buffer(dist = 5000) # 5km radius buffer around lat lon

station_bbox <- station_buffer_sf |>
  dplyr::pull(geometry) |>
  # st_buffer(dist = 10000) |> #in meters
  st_bbox()

#visualize bbox + stations
library(USAboundaries)
library(ggplot2)

az <- us_states(states = "Arizona")

ggplot() +
  geom_sf(data = az) +
  geom_sf(data = station_sf) +
  geom_sf(data = station_buffer_sf, color = "red", fill = NA) +
  annotate(
    geom = "rect",
    fill = NA,
    color = "blue",
    xmin = station_bbox["xmin"],
    xmax = station_bbox["xmax"],
    ymin = station_bbox["ymin"],
    ymax = station_bbox["ymax"]
  )


# example of getting a single file
hour <- hours[1]
stat <- "50pt"

# dir
dir <-
  path(
    glue('/naefs.{strftime(Sys.Date(), "%Y%m%d")}'),
    cycle,
    "pgrb2ap5_bc"
  )
dir
# filename
filename <- glue('naefs_ge{stat}.t{cycle}z.pgrb2a.0p50_bcf{hour}')


# Construct request
req_base <- request("https://nomads.ncep.noaa.gov/cgi-bin/filter_naefsbc.pl") |>
  # req_user_agent("AZMET (jlweiss@arizona.edu)") |> #eventually uncomment
  req_retry()
req <- req_base |>
  req_url_query(
    dir = dir,
    file = filename,
    var_RH = "on",
    var_TMP = "on",
    lev_2_m_above_ground = "on",
    subregion = "", #just how the url is constructed
    toplat = station_bbox["ymax"],
    leftlon = station_bbox["xmin"],
    rightlon = station_bbox["xmax"],
    bottomlat = station_bbox["ymin"]
  )

# download grib2 file
tmp <- tempfile()
resp <- req_perform(req, path = tmp)

# Extract just points
system.time({
  fc_points <- terra::extract(
    terra::rast(tmp),
    station_sf,
    method = "bilinear", #interpolation of 4 nearest pixels
    # method = "simple", #just the value of pixel this point is in
    ID = FALSE
  ) |>
    as_tibble()
  fc_points <- bind_cols(
    station_sf |> as_tibble() |> select(-geometry),
    fc_points
  )
})

# mean of 5km buffer around points
system.time({
  fc_buffer <- exact_extract(
    terra::rast(tmp),
    station_buffer_sf,
    fun = "mean",
    append_cols = TRUE
  ) |>
    as_tibble()
})


#cool, now how would we get all the data we need for each hour?

grid <- tidyr::expand_grid(
  cycle = "00", #assume we get the forecast just once a day
  stat = c("10pt", "50pt", "90pt"), #median, 10th and 90th percentile
  hour = hours[1:40] #5 days
) |>
  mutate(
    dir = path(
      glue('/naefs.{strftime(Sys.Date(), "%Y%m%d")}'),
      cycle,
      "pgrb2ap5_bc"
    ),
    filename = glue('naefs_ge{stat}.t{cycle}z.pgrb2a.0p50_bcf{hour}')
  )

reqs <- map2(grid$dir, grid$filename, \(dir, filename) {
  req_base |>
    req_url_query(
      dir = dir,
      file = filename,
      var_RH = "on",
      var_TMP = "on",
      lev_2_m_above_ground = "on",
      subregion = "", #just how the url is constructed
      toplat = station_bbox["ymax"],
      leftlon = station_bbox["xmin"],
      rightlon = station_bbox["xmax"],
      bottomlat = station_bbox["ymin"]
    )
})

#generate paths in tempdir
paths <- path_temp(grid$filename)

resps <- req_perform_parallel(reqs, paths = paths)
#TODO check for failed responses and deal with them appropriately

#read in all the rasters as layers, clean up the names, then extract all at once and pivot

all <- rast(paths)
lyrnames <- names(all) |>
  # remove elevation
  str_remove("2\\[m\\] HTGL=Specified height level above ground; ") |>
  # two layers per source
  str_c(
    rep(str_extract(sources(all), "(?<=naefs_ge)10pt|50pt|90pt"), each = 2),
    sep = "."
  ) |>

  #TODO: double-check what the correct time zone is

  str_c(format(time(all), tz = "UTC", usetz = TRUE), sep = "_")
names(all) <- lyrnames

fc_data <- terra::extract(
  all,
  station_sf,
  # method = "simple", #just the value of pixel this point is in
  method = "bilinear",
  ID = FALSE
) |>
  as_tibble() |>
  bind_cols(station_info) |>
  pivot_longer(
    starts_with(c("Temperature", "Relative humidity")),
    names_sep = "_",
    names_to = c("var", "datetime"),
    names_transform = list(datetime = as.POSIXct)
  ) |>
  pivot_wider(
    names_from = var,
    values_from = value
  ) |>
  janitor::clean_names()

fc_data |>
  filter(meta_station_id %in% c("az01", "az02", "az04")) |>
  ggplot(aes(x = datetime, color = meta_station_id, fill = meta_station_id)) +
  geom_line(aes(y = relative_humidity_percent_50pt)) +
  geom_ribbon(
    aes(
      ymin = relative_humidity_percent_10pt,
      ymax = relative_humidity_percent_90pt
    ),
    alpha = 0.3,
    color = NA
  )
