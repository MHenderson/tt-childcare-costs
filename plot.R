library(dplyr)
library(ggplot2)
library(targets)

childcare_costs <- tar_read(childcare_costs)

childcare_costs <- childcare_costs |>
  mutate(study_year = as.Date(paste0(study_year, "-01-01")))

childcare_costs |>
  filter(county_fips_code == 21151) |>
  ggplot(aes(study_year, total_pop)) +
    geom_point() +
    geom_line()
