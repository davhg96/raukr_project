# Wine & Climate

A Quarto website exploring the intersection of wine quality and global climate change, built on ~130,000 Wine Enthusiast reviews and 250+ years of global CO2 emissions data.

## Overview

The project is motivated by three questions:

1. Which countries/regions stand out in wine quality, price, and volume, and why?
2. Is there a relationship between wine rating (points) and price?
3. Has the geography of high-scoring wine production shifted toward higher latitudes as cumulative CO2 emissions have grown?

## Site structure

| Page | File | Description |
|---|---|---|
| Home | [index.qmd](index.qmd) | Project motivation, research questions, and data sources |
| Wine quality in the world | [wine-quality-world.qmd](wine-quality-world.qmd) | Average price and production volume by country; points-vs-price correlation (log-price regression) |
| Best wine searcher | [best-wine-searcher.qmd](best-wine-searcher.qmd) | Interactive map/table to find top-rated wines and varieties by country |
| Global warming and wine | [global-warming-wine.qmd](global-warming-wine.qmd) | Cumulative CO2 vs. mean latitude of high-scoring wines over time |

Navigation and theming are configured in [_quarto.yml](_quarto.yml) and [_brand.yml](_brand.yml).

## Data

Raw data comes from Maven Analytics and is **not committed to git** (see `.gitignore`); it must be placed locally before rendering:

- `data/winemag-data-130k-v2.csv` — wine reviews (country, province, region, variety, price, points, reviewer, description, title)
- `data/CO2+Emissions/visualizing_global_co2_data.csv` — country-year CO2 emissions panel, 1750–2021 (with accompanying data dictionary `.xlsx`)
- `data/country_centroids.csv` — country ISO3 codes with lat/long centroids (checked into the repo)

Cleaning and caching logic lives in `R/`:

- `R/wrangle_wine.R` — extracts vintage years from wine titles, maps countries to ISO3 codes, buckets review sentiment, and joins country centroid latitude
- `R/wrangle_co2.R` — selects relevant CO2 columns and filters to valid country codes, plus a helper for the global ("World") aggregate

Each script exposes a `get_*_data()` / `get_co2_world()` function that lazily loads a cached RDS from `data/processed/` if present, or builds and caches it otherwise. These processed files are regenerated automatically on first run and don't need to be created manually.

## Setup & rendering

This project uses [renv](https://rstudio.github.io/renv/) for dependency management.

```r
# Restore R package dependencies
renv::restore()
```

```bash
# Preview the site locally
quarto preview

# Render the full site
quarto render
```

## Deployment

The site is published to [Posit Connect Cloud](https://01a01a69-0073-5952-019b-97a4d2b7f6dd.share.connect.posit.cloud/).

## Key findings

- Wine quality (points) and price show a weak-to-moderate positive correlation once price is log-transformed.
- The mean latitude of high-scoring wines correlates with cumulative CO2 emissions over the full historical record, but only weakly (sparse pre-2000 data); the correlation strengthens considerably when restricted to recent, review-dense years.

## Limitations

- Wine review coverage is sparse before ~2000, which limits the historical analysis.
- Latitude is measured at the country-centroid level, not per-vineyard, so within-country shifts are invisible.
- Observed correlations do not establish that climate change causes the geographic patterns seen; other factors (market dynamics, reviewer/publication coverage) plausibly contribute.
