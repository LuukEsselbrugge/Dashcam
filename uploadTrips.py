import time
import mysql.connector
import os
import requests
import json

REMOTE_ADR = 'https://server.com/upload/addTrip'

mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  passwd="root",
  database="Dashcam"
)
#Wait a bit in case Wifi is not connected yet
time.sleep(15)
#Upload Trip(s)
cursor = mydb.cursor()
cursor.execute("SELECT * FROM Trip", ())
rows = cursor.fetchall()

for row in rows:
	print (row[0])
	
	try:
		cursor.execute("SELECT * FROM TripData WHERE TripID=%s", (row[0],))
		TripData = cursor.fetchall()
		
		multipart_form_data = {
			'video': (row[0]+'.mp4', open('recording/'+row[0]+'.mp4', 'rb')),
		}
	 
		response = requests.post(REMOTE_ADR,files=multipart_form_data,data={'Trip': json.dumps(row, indent=4, sort_keys=True, default=str),'TripData': json.dumps(TripData, indent=4, sort_keys=True, default=str)})
	 
		print(response.status_code)
		
		if(response.status_code == 200):
			print("Trip data and video upload successful!, Deleting local content")
			os.system("rm recording/"+str(row[0])+".mp4")
			mydb.cursor().execute("DELETE FROM Trip WHERE TripID=%s", (str(row[0]),))
			mydb.cursor().execute("DELETE FROM TripData WHERE TripID=%s", (str(row[0]),))
			mydb.commit()
	except Exception:
		print("Could not upload this trip file might be missing")
	
mydb.commit()

