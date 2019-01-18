#!/bin/bash
#MAC adress of OBDII device
rfcomm bind 0 00:1D:A5:68:98:8C
v4l2-ctl -c focus_auto=0
./gpssync -d 5 /dev/ttyAMA0
sleep 3
#Wait for mysql to start
while ! mysqladmin ping -u root -proot --silent; do
    sleep 1
done
######Handle issue where with this car (Peugeot 206 1.6 2002) auxiliary power (Where reset relay is connected) gets turned on for a split second when unlocking car, which resulted in early boot and instant shutdown
gpio mode 9 in
contact=$(gpio read 9)
conSec=("0")
while [ $contact = "1" ]
do
	if [ "$conSecUit" = "300" ]; then #If auxiliary power not on in 5 minutes, turn off car
		shutdown -h now
		exit 1
	fi
	((conSecUit++))
	contact=$(gpio read 9)
	sleep 1
done
######
while true
do
	TripID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

	gpio mode 9 in
	gpio mode 8 out
	gpio write 8 1
	contact=$(gpio read 9)
	conSecUit=("0")

	#Start OBDII recording
	python3 tripData.py $TripID &
	OBD_PID=$!
	#Start Camera recording
	ffmpeg -vsync 1 -async 1 -ar 44100 -ac 2 -f alsa -thread_queue_size 1024 -i hw:1,0 -f v4l2 -codec:v h264 -framerate 30 -video_size 1920x1080 -thread_queue_size 1024 -itsoffset 1 -i /dev/video0 -copyinkf -codec:v copy -codec:a aac -ab 128k -g 10 /recording/$TripID.mp4 &
	CAMERA_ID=$!
	
	#Grace period for Aux power off (In case of stall and need for restart of engine)
	while  [ "$conSecUit" -le "10" ]
	do
		contact=$(gpio read 9)
		if [ $contact = "1" ]; then
			((conSecUit++))
			echo "Contact is uit voor: $conSecUit"
		else
			conSecUit=("0")
		fi
		sleep 1
	done

	echo "Aux power off, Upload process starten"
	#Aux power is off stop OBDII record & Camera record
	kill $OBD_PID
	pkill ffmpeg

	#Start uploading all local trips to remote server
	python3 uploadTrips.py
	#Check if Aux power is still off (In case it came back on while we were uploading)
	if [ $(gpio read 9) ]; then
		echo "Aux power still off, shutdown started"
		shutdown -h now
		exit 1
	fi
done
