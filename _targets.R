# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("dplyr", "ggplot2", "ggthemes", "readr", "sf", "tibble"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  tar_target(
    name = counties,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-09/counties.csv')
  ),
  tar_target(
    name = childcare_costs,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-09/childcare_costs.csv')
  ),
  tar_target(
    name = county_boundaries,
    command = st_read("data-raw/cb_2018_us_county_5m") |>
      mutate(county_fips_code = as.numeric(paste0(STATEFP, COUNTYFP)))
  ),
  tar_target(
    name = childcare_costs_w_county,
    command = left_join(childcare_costs, counties)
  ),
  tar_target(
    name = childcare_counties_sum,
    command = {
      childcare_costs_w_county |>
        filter(study_year >= 2016) |>
        filter(study_year <= 2018) |>
        group_by(county_fips_code) |>
        summarise(
          mean_mc_infant = mean(mc_infant, na.rm = TRUE)
        ) |>
        mutate(
          mean_mc_infant = 52 * mean_mc_infant
        )
    }
  ),
  tar_target(
    name = county_boundaries_w_costs,
    command = left_join(county_boundaries, childcare_counties_sum)
  ),
  tar_target(
    name = states_to_plot,
    command = sprintf("%02d", c(1, 4:13, 16:56))
  ),
  tar_target(
    name = plot_output,
    command = map_plot(county_boundaries_w_costs, states_to_plot)
  ),
  tar_target(
    name = save_plot,
    command = ggsave(plot = plot_output, filename = "plot/infant-center-based.png", bg = "white", width = 10, height = 8),
    format = "file"
  )
)
