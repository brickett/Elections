## Ann Arbor 2021 Election Results
# Bryan Ricketts
# Last Updated: 10/06/2021

#set wd
setwd("~/Academics Grad School/PubPol 683 Elections and Campaigns/Elections")

## Import Shapefiles
library(rgdal)
wash_precincts <- readOGR( 
  dsn= getwd(),
  layer = "VotingPrecinct"
)

#summary(wash_precincts)
A2_precincts <- wash_precincts[wash_precincts$JURISDICTI == "City of Ann Arbor",]

## Check import - plot using ggplot
library(broom)
A2_df <- tidy(A2_precincts, region = "NAME") #ensure rgeos is installed before rgdal is installed

# Plot it
library(ggplot2)
ggplot() +
  geom_polygon(data = A2_precincts, aes( x = long, y = lat, group = group), fill="#69b3a2", color="white") +
  theme_void() 

## Create map using leaflet
library(leaflet)

A2_Transformed <- spTransform(A2_precincts, CRS("+proj=longlat +datum=WGS84 +no_defs"))

library(htmltools)
library(RColorBrewer)
precinct_pal <- colorNumeric(palette = "RdBu", domain = 1:12) #adjust domain to max/min of data

A2_map <- leaflet() %>% 
  addTiles() %>% 
  setView( lng = -83.74, lat = 42.274, zoom = 12 ) %>% 
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = A2_Transformed,
              popup = paste0(htmlEscape(A2_Transformed$NAME), br(), 
                             "Yes: ", htmlEscape(A2_Transformed$WARD_NUM), br(),
                             "No: ", htmlEscape(A2_Transformed$PRCNCT_NUM)),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE),
              weight = 1, opacity = 0.7, color = "black", fillOpacity = 0.45,
              fillColor = precinct_pal(as.numeric(A2_Transformed$PRCNCT_NUM))
                ) %>%
  addLegend("topright", pal = precinct_pal, values = as.numeric(A2_Transformed$PRCNCT_NUM),
            title = "Ward Number", opacity = 0.9)
A2_map

