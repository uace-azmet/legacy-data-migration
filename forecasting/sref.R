library(httr2)
library(terra)
library(glue)
# https://www.nco.ncep.noaa.gov/pmb/products/sref/
# https://nomads.ncep.noaa.gov/

# can get URL to filtered data here: https://nomads.ncep.noaa.gov/gribfilter.php?ds=sref

#bounding box for AZ
az_bb <- c(
  leftlon = -114.8128344705447,
  bottomlat = 31.332406253852533,
  rightlon = -109.04483902389023,
  toplat = 37.0039183311733
)


url <- "https://nomads.ncep.noaa.gov/cgi-bin/filter_sref.pl?dir=%2Fsref.20250602%2F15%2Fpgrb&file=sref_arw.t15z.pgrb212.ctl.f00.grib2&var_APCP=on&var_TMP=on&lev_surface=on&subregion=&toplat=37.0039183311733&leftlon=-114.8128344705447&rightlon=-109.04483902389023&bottomlat=31.332406253852533"
req <- request(url)
tmp <- tempfile()
resp <- req_perform(req, path = tmp)
x <- terra::rast(tmp)
names(x)
plot(x)

# reverse engineer request with httr2
cycles <- c("03", "09", "15", "21")
cycle <- cycles[1]
date <- format(Sys.Date(), "%Y%m%d")
dirs <- c(
  "40km CONUS" = "pgrb",
  "40km CONUS Bias-Corrected" = "pgrb_bias",
  "32km North America" = "pgrb"
  #there is a 16km option, but would need to provide forecast hours in filename
)
dir <- dirs["40km CONUS"]

models <- c(
  "NEMS Non-hydrostatic Multiscale Model on the B grid (NMMB)" = "nmb",
  "Eulerian Mass (EM) -core (Advanced Research WRF (ARW))" = "arw"
)
model <- models[1]

grids <- c(
  "40km CONUS" = "pgrb212",
  "40km CONUS Bias-Corrected" = "pgrb212",
  "32km North America" = "pgrb221"
)
grid <- grids["40km CONUS"]

ensembles <- c(
  "ctl",
  paste0(rep(c("p", "n"), each = 6), rep(1:6, 2))
)
ensemble <- ensembles[1]

hours <- formatC(0:87, width = 2, flag = 0)
hour <- hours[1]

req2 <- request("https://nomads.ncep.noaa.gov/cgi-bin/filter_sref.pl") |>
  req_url_query(
    dir = glue("/sref.{date}/{cycle}/{dir}"),
    file = glue("sref_{model}.t{cycle}z.{grid}.{ensemble}.f{hour}.grib2"), #TODO: this is the ensemble member, need to construct programmatically
    var_APCP = "on", #total precipitation
    var_TMP = "on", #temperature,
    lev_surface = "on",
    subregion = "",
    !!!az_bb
  )
tmp2 <- tempfile()
resp2 <- req_perform(req2, path = tmp2)
x2 <- rast(tmp2)
names(x2)
plot(x2)

#or get ensemble mean and spread product, but grib filtering not available I think?
req3 <- request(
  "https://nomads.ncep.noaa.gov/pub/data/nccf/com/sref/prod/sref.20250602/03/ensprod/sref.t03z.pgrb212.mean_1hrly.grib2"
)
tmp3 <- tempfile()
resp3 <- req_perform(req3, path = tmp3)
x3 <- rast(tmp3)
names(x3)

req4 <- request(
  "https://nomads.ncep.noaa.gov/pub/data/nccf/com/sref/prod/sref.20250602/03/ensprod/sref.t03z.pgrb212.p50_1hrly.grib2"
)
tmp4 <- tempfile()
resp4 <- req_perform(req4, tmp4)
x4 <- rast(tmp4)
names(x4)
#surface precip I think

plot(x3[[859]])

str_detect(names(x4), "Total precipitation") |> which()
names(x4)[56]

plot(x4[[56]])
names(x4) #names appear to be repeated, one for each hour I guess?

names(x4)[
  names(x4) == "2[m] HTGL=Specified height level above ground; Temperature [C]"
]
# Inventory for uncertainty products is missing, so maybe don't use this method
# Inventory for spread shows that repeated columns are different hourly forecasts:
# https://www.nco.ncep.noaa.gov/pmb/products/sref/sref.t03z.pgrb212.spread_1hrly.grib2.shtml

naefs_req <- request(
  "https://nomads.ncep.noaa.gov/cgi-bin/filter_naefsbc.pl?dir=%2Fnaefs.20250602%2F12%2Fpgrb2ap5_bc&file=naefs_ge50pt.t12z.pgrb2a.0p50_bcf003&var_TMP=on&lev_2_m_above_ground=on&subregion=&toplat=37.0039183311733&leftlon=-114.8128344705447&rightlon=-109.04483902389023&bottomlat=31.332406253852533"
)
tmp <- tempfile()
naefs_resp <- req_perform(naefs_req, path = tmp)
naefs_50pt <- rast(tmp)
plot(naefs_50pt)
naefs_50pt
