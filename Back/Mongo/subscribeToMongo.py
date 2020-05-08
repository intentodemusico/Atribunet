import paho.mqtt.client as mqtt
import pymongo
import json
broker = "broker.hivemq.com"
port = 1883

client = pymongo.MongoClient('mongodb+srv://analytica:toorpedo@cluster0-c282b.mongodb.net/test?retryWrites=true&w=majority')
db = client.analytica.analytica
if(db):
	print("Connected to mongo.")
# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
	print("Connected to MQTT broker, with result code "+str(rc))
	# Subscribing in on_connect() means that if we lose the connection and
	# reconnect then subscriptions will be renewed.
	#client.subscribe("$SYS/#")
	client.subscribe("analytica/data")
	client.subscribe("analytica/mongo")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
	on=1 if(msg.topic=="analytica/mongo" and str(msg.payload)[2:-1]=="1") else 0
	if(on==1):
		m=json.loads(msg.payload)
		post=str(msg.payload)[2:-1]
		posts_id=db.insert_one(m).inserted_id
		if(posts_id):
			print("Mongo: Inserted->",str(m))
		else:
			print("Mongo: Error")
	
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect(broker,port)
# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
client.loop_forever()
