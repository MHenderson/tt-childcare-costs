library(ggplot2)
library(targets)
library(sf)

counties <- st_read("data-raw/cb_2018_us_county_5m")

lower48_counties <- counties[
  counties$STATEFP %in% c("01", "04", "05", "06", "08", "09", "10", "11", "12", "13", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56")
  , ]

ggplot() +
  geom_sf(data = lower48_counties)

