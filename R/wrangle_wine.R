# Load and clean the winemag wine-tasting reviews dataset.
#
# Key steps:
#   - extract a numeric vintage year from the free-text `title` column
#   - harmonize `country` to ISO3 codes for joining against the CO2 dataset
#     and for choropleth maps
#   - attach an approximate wine-region latitude (see data/country_centroids.csv)
#   - bucket reviews into positive / neutral / negative for text mining
#
# Produces data/processed/wine_clean.rds

library(readr)
library(dplyr)
library(stringr)
library(countrycode)

#' Extract a plausible vintage year from a wine title.
#'
#' Titles often embed extra 4-digit numbers unrelated to the vintage (e.g.
#' winery founding years like "Hazlitt 1852 Vineyards 2013 Chardonnay"), and
#' non-vintage wines use the literal token "NV" instead of a year. We pull all
#' (18|19|20)xx tokens, keep the ones in a plausible vintage window
#' (1900-2025), and take the most recent one: founding years predate this
#' window's likely low bound in practice for wines in this dataset, while the
#' true vintage is always the latest 4-digit token present.
extract_vintage <- function(title) {
  matches <- str_extract_all(title, "(?<!\\d)(18|19|20)\\d{2}(?!\\d)")
  vapply(matches, function(x) {
    x <- as.integer(x)
    x <- x[x >= 1900 & x <= 2025]
    if (length(x) == 0) NA_integer_ else max(x)
  }, integer(1))
}

load_wine_data <- function(
  path = "data/winemag-data-130k-v2.csv",
  centroids_path = "data/country_centroids.csv"
) {
  wine_raw <- read_csv(path, show_col_types = FALSE)
  centroids <- read_csv(centroids_path, show_col_types = FALSE)

  wine_raw |>
    mutate(
      vintage = extract_vintage(title),
      country_iso3 = countrycode(
        country,
        origin = "country.name",
        destination = "iso3c",
        custom_match = c(England = "GBR")
      ),
      review_sentiment = case_when(
        points >= 90 ~ "positive",
        points <= 85 ~ "negative",
        TRUE ~ "neutral"
      )
    ) |>
    left_join(
      centroids |> select(country_iso3 = iso3, wine_region_latitude),
      by = "country_iso3"
    )
}

cache_wine_data <- function(
  path = "data/winemag-data-130k-v2.csv",
  centroids_path = "data/country_centroids.csv",
  out_path = "data/processed/wine_clean.rds"
) {
  dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
  wine_clean <- load_wine_data(path, centroids_path)
  saveRDS(wine_clean, out_path)
  wine_clean
}

get_wine_data <- function(
  out_path = "data/processed/wine_clean.rds",
  path = "data/winemag-data-130k-v2.csv",
  centroids_path = "data/country_centroids.csv"
) {
  if (file.exists(out_path)) {
    readRDS(out_path)
  } else {
    cache_wine_data(path, centroids_path, out_path)
  }
}
