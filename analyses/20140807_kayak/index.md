# Riffle-ito + Thermistor Kayak Deployment
Jeffrey D Walker, PhD  
August 7, 2014  

![Panorama](img/panorama.jpg)

I attached a riffle-ito to my kayak and paddled around the Androscoggin River. I also had an Arduino Uno with a GPS Shield logging my location. Here's what it looked like:

![Kayak Setup](img/kayak.jpg)

To keep the enclosure submerged, I tied a bag of rocks to it.

![Rocks](img/rocks.jpg)

## R Libraries


```r
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(ggmap)
theme_set(theme_bw())
```

## GPS Data


```r
gps <- read.csv('./data/GPSLOG02.CSV', header=FALSE, as.is=TRUE)
names(gps) <- c('DATETIME_UTC','FIX','FIX_QUALITY','LATITUDE','LONGITUDE','SPEED','ANGLE','ALTITUDE','NUM_SATELLITES')
gps <- mutate(gps, DATETIME=ymd_hms(DATETIME_UTC, tz="UTC") %>% with_tz(tzone="US/Eastern"),
              LATITUDE=floor(LATITUDE/100) + (LATITUDE %% 100)/60,
              LONGITUDE=floor(LONGITUDE/100) + (LONGITUDE %% 100)/60,
              LONGITUDE=-LONGITUDE) %>%
  filter(LATITUDE > 0)
```

Here are the locations recorded by the GPS, which show the path of the kayak:


```r
map <- get_map(location=c(lon=mean(range(gps$LONGITUDE)), lat=mean(range(gps$LATITUDE))),
               zoom=15, maptype="satellite")
```

```
## Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=43.919103,-69.951928&zoom=15&size=%20640x640&scale=%202&maptype=satellite&sensor=false
## Google Maps API Terms of Service : http://developers.google.com/maps/terms
```

```r
ggmap(map, darken=c(0.25, "white"), extent="device") +
  geom_point(aes(LONGITUDE, LATITUDE), data=gps, color='red', size=1)
```

![plot of chunk map_path](./index_files/figure-html/map_path.png) 

## Riffle-ito Data


```r
wq <- read.csv('data/LOGGER22.CSV', as.is=TRUE)
wq <- mutate(wq, DATETIME=ymd_hms(DATETIME, tz="US/Eastern"))
head(wq)
```

```
##              DATETIME RTC_TEMP_C TEMP_C BATTERY_LEVEL
## 1 2014-08-07 17:58:59      23.25  24.16           706
## 2 2014-08-07 18:00:02      23.25  24.07           706
## 3 2014-08-07 18:01:04      23.25  24.07           706
## 4 2014-08-07 18:02:07      23.25  23.99           706
## 5 2014-08-07 18:03:09      23.00  23.81           706
## 6 2014-08-07 18:04:12      22.75  23.46           706
```

Here is a timeseries of the riffle-ito temperature. Note the high temperature at the beginning and low temperature at the end are not actually measurements of the water temperature, but rather the air temperature as I moved the riffle from my house to the kayak before setting out, and then back from the kayak to the house after returning.


```r
ggplot(wq, aes(DATETIME, TEMP_C)) +
  geom_line() +
  labs(x="Time", y="Temp (degC)")
```

![plot of chunk plot_temp](./index_files/figure-html/plot_temp.png) 

## Merge GPS and Riffle-ito Data

To merge the GPS and Riffle-ito data, first I'll compute the mean location and mean temperature at 1-minute intervals. Then I'll join the two tables by the 1-minute rounded DATETIME.


```r
wq.1min <- group_by(wq, DATETIME=round_date(DATETIME, unit='minute')) %>%
  summarise(N.WQ=n(),
            TEMP_C=mean(TEMP_C))
gps.1min <- group_by(gps, DATETIME=round_date(DATETIME, unit='minute')) %>%
  summarise(N.GPS=n(),
            LATITUDE=mean(LATITUDE),
            LONGITUDE=mean(LONGITUDE))
df <- merge(wq.1min, gps.1min, by="DATETIME", all=TRUE)
```

## Temperature Map

This map shows the track with points colored by temperature. The data are filtered to only show values when the sensor was in the water.


```r
ggmap(map, darken=c(0.25, "white"), extent="device") +
  geom_point(aes(LONGITUDE, LATITUDE, color=TEMP_C), 
             data=filter(df, DATETIME>=ymd_hm("2014-08-07 18:10", tz="US/Eastern"), 
                             DATETIME<=ymd_hm("2014-08-07 19:17", tz="US/Eastern")), 
             size=1) +
  scale_color_gradient(low='green', high='red')
```

![plot of chunk map_temp](./index_files/figure-html/map_temp.png) 

### Outfall

I expected to see a change around the Brunswick Water Treatment Plant outfall. The following map zooms into this location (you can see the treatment plant in the lower left). 


```r
df.outfall <- filter(df, DATETIME>=ymd_hm("2014-08-07 18:30", tz="US/Eastern"), 
                         DATETIME<=ymd_hm("2014-08-07 18:57", tz="US/Eastern"))
map.outfall <- get_map(location=c(lon=mean(range(df.outfall$LONGITUDE)), 
                                  lat=mean(range(df.outfall$LATITUDE))),
                       zoom=17, maptype="satellite")
                      
ggmap(map.outfall, darken=c(0.25, "white"), extent="device") +
  geom_point(aes(LONGITUDE, LATITUDE, color=TEMP_C), 
             data=df.outfall, 
             size=3) +
  scale_color_gradient(low='green', high='red')
```

![plot of chunk map_outfall](./index_files/figure-html/map_outfall.png) 

Here is a photo of the outfall.

![Outfall](img/outfall.jpg)

Unfortunately, we don't see much difference. The outfall temperature is probably similar to the water temperature at this time of year. However, the lowest temperature point (the green point) is located right next to the outfall.

### Return Trip Temperature

You can however see how the temperature dropped on the return trip, which was close to sunset and thus probably reflects the cooling air temperature. This figure shows the temperature values, with the shapes of the symbols indicating whether the point was collected as I was heading out to the outfall or heading back to the house.


```r
ggmap(map, darken=c(0.25, "white"), extent="device") +
  geom_point(aes(LONGITUDE, LATITUDE, color=TEMP_C, 
                 shape=DATETIME>=ymd_hm("2014-08-07 18:50", tz="US/Eastern")), 
             data=filter(df, DATETIME>=ymd_hm("2014-08-07 18:10", tz="US/Eastern"), 
                             DATETIME<=ymd_hm("2014-08-07 19:17", tz="US/Eastern")), 
             size=2) +
  scale_color_gradient(low='green', high='red') +
  scale_shape_discrete("Direction", labels=c("Heading Out", "Heading Back"))
```

![plot of chunk map_temp_return](./index_files/figure-html/map_temp_return.png) 

And this compares the same values as a timeseries. I'm not sure what caused the blips in this figure.


```r
filter(df, DATETIME>=ymd_hm("2014-08-07 18:10", tz="US/Eastern"), 
                             DATETIME<=ymd_hm("2014-08-07 19:17", tz="US/Eastern")) %>%
  mutate(DIRECTION=DATETIME>=ymd_hm("2014-08-07 18:50", tz="US/Eastern")) %>%
  ggplot(aes(DATETIME, TEMP_C, color=TEMP_C, 
             shape=DATETIME>=ymd_hm("2014-08-07 18:50", tz="US/Eastern"))) +
  geom_point() +
  geom_line() +
  scale_color_gradient(low='green', high='red') +
  scale_shape_discrete("Direction", labels=c("Heading Out", "Heading Back")) +
  labs(x="Time", y="Temp (degC)")
```

```
## Warning: Removed 3 rows containing missing values (geom_point).
```

![plot of chunk plot_temp_ts](./index_files/figure-html/plot_temp_ts.png) 

## Conclusions

- The VOSS water bottle enclosure seemed to work and keep the riffle-ito dry.
- The GPS shield worked great.
- I forgot to change the measurement frequency of the riffle-ito, which was set to 60 seconds. I should have reduced this to 10 seconds (or less) to take more measurements as battery life was not a major concern.
- To keep the riffle-ito submerged, I tied a bag of rocks to it. This seemed to work, but induced significant drag and made it harder to paddle (I should have anticipated this). The depth of the sensor also varied from approximately 1-2 ft below the water surface to within an inch of the surface depending on my speed (higher speed, less depth). It would be ideal to keep the sensor at a constant depth as temperature may decrease with depth. So a more robust and stable contraption is needed for dragging the riffle-ito behind a kayak. 
- I detected no significant temperature signature from the outfall. I suspect this is because the temperature of the outfall discharge is similar to that of the river water at this time of year. Repeating this experiment in the fall may reveal a stronger signal as the outfall temperature will likely be higher than the river temperature. Conductivity measurements will also likely show an effect of the outfall.
