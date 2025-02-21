library(targets)

tar_option_set(
  packages = c("dplyr", "ggplot2", "ggthemes", "readr", "sf", "tibble", "tigris"), 
    format = "rds"
)

tar_source()

list(
  tar_target(
       name = counties_df,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-09/counties.csv')
  ),
  tar_target(
       name = childcare_costs,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2023/2023-05-09/childcare_costs.csv')
  ),
  tar_target(
       name = us_county_5m,
    command = counties(cb = TRUE, resolution = "5m")
  ),
  tar_target(
       name = county_boundaries,
    command = us_county_5m |>
      mutate(county_fips_code = as.numeric(paste0(STATEFP, COUNTYFP)))
  ),
  tar_target(
       name = childcare_costs_w_county,
    command = left_join(childcare_costs, counties_df)
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
    command = {
      county_boundaries_w_costs |>
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
	  legend.position = c(.82, .9),
	      plot.margin = margin(0, 1, 0, 1, "cm"),
	) +
	labs(
	      fill = "Median yearly price (2018 dollars)",
	     title = "Childcare Prices by Age of Children and Care Setting",
	  subtitle = "Infant center-based",
	   caption = "Source: National Database of Childcare Prices 2016 - 2018,
	     Women's Bureau, U.S. Department of Labor."
	)
    }
  ),
  tar_target(
       name = save_plot,
     format = "file",
    command = ggsave(
          plot = plot_output,
      filename = "plot/infant-center-based.png",
            bg = "white",
         width = 10,
	height = 8
    )
  )
)
