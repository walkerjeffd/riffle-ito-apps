Riffle-ito Water Quality Sensor
=======================

[Jeffrey D. Walker, PhD](http://walkerjeff.com)

This repo contains sketches for programming the 
[Riffle-ito](https://github.com/p-v-o-s/riffle-ito) Water Quality Sensor 
developed by [Don Blair](https://github.com/p-v-o-s), and analysis of data collected
by the Riffle-ito.

## Analyses

Here are direct links to each analysis document:

- [20140715_dht22_logger](https://github.com/walkerjeffd/riffle-ito-apps/blob/master/analyses/20140715_dht22_logger/index.md): deployment of a riffle-ito with DHT22 temperature/humidity sensor to test battery life, stability, and compare RTC temperature to DHT22 temperature readings.
- [20140725_cambridge](https://github.com/walkerjeffd/riffle-ito-apps/blob/master/analyses/20140725_cambridge/index.md): first field deployment of two riffle-itos measuring temperature, conductivity and light levels located at a USGS gage for verification.
- [20140731_thermistor](https://github.com/walkerjeffd/riffle-ito-apps/blob/master/analyses/20140731_thermistor/index.md): deployment of riffle-ito with 10K thermistor to test battery life, stability, and compare RTC temperature to thermistor.

## Description

This repo currently contains two things:

1. `ino/`: directory contains 'Arduino' sketches that are uploaded to the Riffle-ito. Each folder currently contains a `*.ino` file that can be opened in the Arduino IDE and uploaded to a riffle-ito.
2. `analyses/`: analyses of data collected by Riffle-ito. Each folder contains the data files in `*.csv` format and a set of `index.Rmd`, `index.md` and `index.html` files. The `index.Rmd` file is an R markdown document that serves as the source code for the analysis. This file is written using [RStudio](http://www.rstudio.com/), and then compiled first to a markdown file (`index.md`) and then an html file (`index.html`) using the [rmarkdown](http://rmarkdown.rstudio.com/) package integrated with RStudio. To view the analysis, simply click on the `index.md` file in github (e.g. [this one](https://github.com/walkerjeffd/riffle-ito-apps/blob/master/analyses/20140715_dht22_logger/index.md)), which will automatically format the markdown file for enjoyable reading.

## Required Libraries

- [JeeLib](https://github.com/jcw/jeelib): for low power mode using `Sleepy::loseSomeTime()`
- [DHTlib](https://github.com/adafruit/DHT-sensor-library): [@adafruit](https://github.com/adafruit) library for using the DHT22 temperature/humidity sensor
- [RTClib](https://github.com/mizraith/RTClib): [@mizraith](https://github.com/mizraith) fork of Jeelab's RTClib that includes support for DS3231.

## Hardware Setup

### DHT22 Set Up

DHT22 connected to Riffle-ito with red wire to 3.3v, black wire to GND, yellow wire to A1 pin

Optionally, connect LED to pin A2 and GND (with resistor, see [blink](http://arduino.cc/en/tutorial/blink)).

### Thermister Set Up

Thermister connected to analog pin A1 with 10k resister in series connected to 3.3v (see [Adafruit Thermister Tutorial](https://learn.adafruit.com/thermistor/overview)).

## Arduino IDE Configuration

Select Arduino Uno as Board Type (`Tools > Board > Arduino Uno`)

Select appropriate serial port (via trial and error)

## Deployment

When deploying the Riffle-ito, be sure to set the `debug` variable in each sketch to 0. Doing this enables low power mode via Jeelib's `Sleepy::loseSomeTime`. This also turns off serial debugging.

### References

- [Adafruit Data Logger Shield Tutorial](https://learn.adafruit.com/adafruit-data-logger-shield/overview)
- [Adafruit Thermister Tutorial](https://learn.adafruit.com/thermistor/overview)
- [Adafruit DHTxx Tutorial](https://learn.adafruit.com/dht/overview)

### License

MIT (see [LICENSE](./LICENSE))