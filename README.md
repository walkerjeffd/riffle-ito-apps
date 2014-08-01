Riffle-ito Water Quality Sensor
=======================

[Jeffrey D. Walker, PhD](http://walkerjeff.com)

This repo contains sketches for programming the 
[Riffle-ito](https://github.com/p-v-o-s/riffle-ito) Water Quality Sensor 
developed by [Don Blair](https://github.com/p-v-o-s).

## Required Libraries

- [JeeLib](https://github.com/jcw/jeelib)
- [DHTlib](https://github.com/adafruit/DHT-sensor-library): for using the DHT22 temperature/humidity sensor
- [RTClib](https://github.com/mizraith/RTClib) - mizraith's fork of Jeelab's RTClib that includes support for DS3231.

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
- [Adafruit DHTxx Tutorial](https://learn.adafruit.com/thermistor/overview)