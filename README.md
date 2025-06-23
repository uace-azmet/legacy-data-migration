# legacy-data-migration
code for formatting hourly and daily legacy data files for API


Files:

- air.toml: Config file indicating that this project uses the [`air` formatter](https://posit-dev.github.io/air/formatter.html)
- azmet-station-list.csv: a list of stations with legacy data to migrate
- azmet.schema.20250516-1222-1.sql: a SQL schema provided by Matt Harmon
- parsing_problems.R: script to (slowly) attempt scraping all data and saving out the result of `readr::problems()` in a named list to help troubleshoot parsing issues
- run.R: script to run functions to scrape all hourly and daily data for all stations and write to CSVs
- R/
    - azmet_daily_datat_download.R: function for downloading all daily data for a single station
    - azmet_hourly_data_download.R: function for downloading all hourly data for a single station
    - utils.R: contains helper functions for unit conversions and dealing with the fact that AZMET uses 24:00:00 for midnight unlike R which rounds to the next day at 00:00:00. Must `source()` this for the data download functions to work.