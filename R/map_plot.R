map_plot <- function(X, states_to_plot) {
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