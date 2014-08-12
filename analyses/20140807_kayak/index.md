# Riffle-ito + Thermistor Kayak Deployment
Jeffrey D Walker, PhD  
August 7, 2014  

![Panorama](img/panorama.jpg)

## What I Did

I attached a [riffle-ito](https://github.com/p-v-o-s/riffle-ito/) to my kayak and paddled around the Androscoggin River. I also had an Arduino Uno with a GPS Shield logging my location. 

Here's what the set up looked like:

![Kayak Setup](img/kayak.jpg)

To keep the enclosure submerged, I tied a bag of rocks to it.

![Rocks](img/rocks.jpg)

Here is a video showing some highlights from the deployment.

<iframe width="560" height="315" src="//www.youtube.com/embed/t26eL-m8-zo?fs=1" frameborder="0" allowfullscreen></iframe>

Note: This is an Rmarkdown document. The [data files](https://github.com/walkerjeffd/riffle-ito-apps/tree/master/analyses/20140807_kayak/data) and [source code](https://github.com/walkerjeffd/riffle-ito-apps/blob/master/analyses/20140807_kayak/index.Rmd) used to generate this document all the figures are available in the github [repo](https://github.com/walkerjeffd/riffle-ito-apps).



## Results

### GPS Data



Here's what the GPS data looks like:


```r
head(gps)
```

```
##           DATETIME_UTC FIX FIX_QUALITY LATITUDE LONGITUDE SPEED ANGLE
## 1 2014-8-7 22:6:17.984   1           1    43.92    -69.96  0.15   0.0
## 2 2014-8-7 22:6:20.953   1           1    43.92    -69.96  1.01 348.1
## 3   2014-8-7 22:6:24.0   1           1    43.92    -69.96  0.34 346.2
## 4   2014-8-7 22:6:27.0   1           1    43.92    -69.96  0.16 346.2
## 5   2014-8-7 22:6:30.0   1           1    43.92    -69.96  0.12 346.2
## 6 2014-8-7 22:6:32.984   1           1    43.92    -69.96  0.08 346.2
##   ALTITUDE NUM_SATELLITES            DATETIME
## 1     11.3             10 2014-08-07 18:06:17
## 2      3.3             10 2014-08-07 18:06:20
## 3      2.7              9 2014-08-07 18:06:24
## 4      2.9             11 2014-08-07 18:06:27
## 5      2.9             11 2014-08-07 18:06:30
## 6      2.3             11 2014-08-07 18:06:32
```

This map shows the locations recorded by the GPS:

![plot of chunk map_path](./index_files/figure-html/map_path.png) 

### Riffle-ito Data



Here's what the riffle-tio data look like.


```r
head(riffle)
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

![plot of chunk plot_temp](./index_files/figure-html/plot_temp.png) 

### Merge GPS and Riffle-ito Data

To merge the GPS and Riffle-ito data (which are in separate data tables), I computed the mean location and mean temperature at 1-minute intervals. Then I joined the two tables by the 1-minute rounded timestamps.



The data now look like this:


```r
head(df)
```

```
##              DATETIME N.WQ TEMP_C N.GPS LATITUDE LONGITUDE
## 1 2014-08-07 18:06:00    1  23.03     4    43.92    -69.96
## 2 2014-08-07 18:07:00    1  22.94    20    43.92    -69.96
## 3 2014-08-07 18:08:00    1  22.59    20    43.92    -69.96
## 4 2014-08-07 18:09:00    1  21.81    20    43.92    -69.96
## 5 2014-08-07 18:10:00    1  22.42    20    43.92    -69.96
## 6 2014-08-07 18:11:00   NA     NA    21    43.92    -69.96
```

#### Temperature Map

This map shows the track with points colored by temperature. The data are filtered to only show values when the sensor was in the water.

![plot of chunk map_temp](./index_files/figure-html/map_temp.png) 

#### Outfall

I expected to see a change around the Brunswick Water Treatment Plant outfall. The following map zooms into this location (you can see the treatment plant in the lower left). 

![plot of chunk map_outfall](./index_files/figure-html/map_outfall.png) 

Here is a photo of the outfall.

![Outfall](img/outfall.jpg)

Unfortunately, I didn't see much difference. The outfall temperature is probably similar to the water temperature at this time of year. However, the lowest temperature point (the green point) is located right next to the outfall.

#### Return Trip Temperature

You can however see how the temperature dropped on the return trip, which was close to sunset and thus probably reflects the cooling air temperature. This figure shows the temperature values, with the shapes of the symbols indicating whether the point was collected as I was heading out to the outfall or heading back to the house.

![plot of chunk map_temp_return](./index_files/figure-html/map_temp_return.png) 

And this compares the same values as a timeseries. I'm not sure what caused the blips in this figure.

![plot of chunk plot_temp_ts](./index_files/figure-html/plot_temp_ts.png) 

## Conclusions

- The VOSS water bottle enclosure seemed to work and keep the riffle-ito dry.
- The GPS shield worked great.
- I forgot to change the measurement frequency of the riffle-ito, which was set to 60 seconds. I should have reduced this to 10 seconds (or less) to take more measurements as battery life was not a major concern.
- To keep the riffle-ito submerged, I tied a bag of rocks to it. This seemed to work, but induced significant drag and made it harder to paddle (I should have anticipated this). The depth of the sensor also varied from approximately 1-2 ft below the water surface to within an inch of the surface depending on my speed (higher speed, less depth). It would be ideal to keep the sensor at a constant depth as temperature may decrease with depth. So a more robust and stable contraption is needed for dragging the riffle-ito behind a kayak. 
- I detected no significant temperature signature from the outfall. I suspect this is because the temperature of the outfall discharge is similar to that of the river water at this time of year. Repeating this experiment in the fall may reveal a stronger signal as the outfall temperature will likely be higher than the river temperature. Conductivity measurements will also likely show an effect of the outfall.
