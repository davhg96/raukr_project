# Load and trim the CO2 emissions dataset down to the columns and year range
# relevant to the wine analysis.
#
# We keep the full historical record up through the latest available CO2
# year, upper-bounded implicitly by the data itself; the "global-warming and
# wine" page further restricts the slider range to
# [min(wine$vintage), max(co2$year)] at render time, since the interesting
# comparison window is anchored to when wine vintages in our data begin.
#
# Produces data/processed/co2_clean.rds

library(readr)
library(dplyr)

#data loading and cleaning a bit
load_co2_data <- function(path = "data/CO2+Emissions/visualizing_global_co2_data.csv") {
  read_csv(path, show_col_types = FALSE) |>
    select(
      country, iso_code, year,
      population, gdp,
      co2, co2_growth_prct, co2_per_capita,
      cumulative_co2, share_global_cumulative_co2
    ) |>
    filter(!is.na(iso_code), nchar(iso_code) == 3)
} 

#Data saving
cache_co2_data <- function(
  path = "data/CO2+Emissions/visualizing_global_co2_data.csv",
  out_path = "data/processed/co2_clean.rds"
) {
  dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
  co2_clean <- load_co2_data(path)
  saveRDS(co2_clean, out_path)
  co2_clean
}

#Data loading
get_co2_data <- function(
  out_path = "data/processed/co2_clean.rds",
  path = "data/CO2+Emissions/visualizing_global_co2_data.csv"
) {
  if (file.exists(out_path)) {
    readRDS(out_path)
  } else {
    cache_co2_data(path, out_path)
  }
}

# The dataset includes a "World" aggregate row (iso_code is NA), which
# load_co2_data() excludes since it isn't a real country for choropleth
# purposes. We keep it separately for global cumulative-CO2 trends.
load_co2_world <- function(path = "data/CO2+Emissions/visualizing_global_co2_data.csv") {
  read_csv(path, show_col_types = FALSE) |>
    filter(country == "World") |>
    select(year, cumulative_co2, co2)
}

get_co2_world <- function(
  out_path = "data/processed/co2_world.rds",
  path = "data/CO2+Emissions/visualizing_global_co2_data.csv"
) {
  if (file.exists(out_path)) {
    readRDS(out_path)
  } else {
    dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
    co2_world <- load_co2_world(path)
    saveRDS(co2_world, out_path)
    co2_world
  }
}
