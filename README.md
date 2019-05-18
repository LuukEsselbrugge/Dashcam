# Automated OBDII car Dashcam system

----
## What is Dashcam?
A fully automated Dashcam system written for the Raspberry pi in bash and Python3. It will record trips and upload these to a server when Wifi is available

![Preview](https://i.imgur.com/E8bVDzm.jpg)
[MoreImages](https://imgur.com/a/HetpOQ9)

**Work in progress**

## Software
**Python3**

* mysql connector
* json
* requests
* pySerial
* pynmea2

**Linux packages (Raspberry pi)**

* rfcomm
* mysqladmin
* WiringPi
* gpsdate (Pre compiled ARM binary included) [Link](https://github.com/adamheinrich/gpsdate)
* v4l-utils (For disabling autofocus on Logitech C920, optional)
* ffmpeg
* mysql server

For automatic launch on boot **crontab -e**

    # m h dom mon dow command 
    @reboot sudo screen -dm -S cd /home/pi/ && sudo bash main.sh

**Bluetooth Pairing**

Pair your OBDII device using bluetoothctl before launch

**Database**

* Create a new database called Dashcam
* Import the included sql file into Dashcam

**Extra**
Create a folder called "recording" in the project root

## Hardware
**Components**

* Raspberry PI
* Logitech C920
* NEO-6M GPS module (Serial)
* Relay
* ~12V to 5V converter
* ELM327 OBDII Bluetooth adapter

**Connections**

* GPS serial TX/RX to Raspberry pi UART RX/TX
* Camera to any USB port
* Relay connected to auxiliary power of car (on when key in aux position) to Raspberry pi GPIO pin 9 (reset) and ground

I experienced issues when using the onboard bluetooth of the Raspberry pi 3 (Kernel panics) I could not figure this issue out so for now I use a cheap Bluetooth USB dongle

