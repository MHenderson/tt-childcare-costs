library(dplyr)
library(ggplot2)
library(ggthemes)
library(targets)
library(sf)

# https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
counties <- st_read("data-raw/cb_2018_us_county_5m") |>
  mutate(county_fips_code = as.numeric(paste0(STATEFP, COUNTYFP)))
  
# https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-05-09/readme.md
childcare_counties <- tar_read(childcare_costs_w_county)

childcare_counties_sum <- childcare_counties |>
  filter(study_year >= 2016) |>
  filter(study_year <= 2018) |>
  group_by(county_fips_code) |>
  summarise(
    mean_mc_infant = mean(mc_infant, na.rm = TRUE)
  ) |>
  mutate(
    mean_mc_infant = 52 * mean_mc_infant
  )

X <- counties |>
  left_join(childcare_counties_sum)

states_to_plot <- sprintf("%02d", c(1, 4:13, 16:56))

X |>
  filter(STATEFP %in% states_to_plot) |>
  ggplot() +
    geom_sf(aes(fill = mean_mc_infant)) +
    scale_fill_continuous_tableau(na.value = "#d9d5c9") +
    guides(
      fill = guide_colourbar(
        barwidth = 8,
        barheight = 1,
        title.position = "top",
        direction = "horizontal"
      )
    ) +
    theme_void() +
    theme(
      legend.position = c(.8, .9)
    ) +
    labs(
      fill = "Median yearly price ($)"
    )

# hawaii
X |>
  filter(STATEFP == 15) |>
  ggplot() +
  geom_sf(aes(fill = mean_mc_infant)) +
  scale_fill_continuous_tableau(na.value = "#d9d5c9") +
  theme_void() +
  theme(
    legend.position = "none"
  )

# alaska
X |>
  filter(STATEFP == "02") |>
  ggplot() +
  geom_sf(aes(fill = mean_mc_infant)) +
  scale_fill_continuous_tableau(na.value = "#d9d5c9") +
  theme_void() +
  theme(
    legend.position = "none"
  )

# https://sesync-ci.github.io/blog/transform-Alaska-Hawaii.html
