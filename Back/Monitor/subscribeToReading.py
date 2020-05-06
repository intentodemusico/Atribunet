import paho.mqtt.client as mqtt
import json
broker = "broker.hivemq.com"
port = 1883

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT broker, with result code "+str(rc))
    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    #client.subscribe("$SYS/#")
    client.subscribe("analytica/data")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    post=str(msg.payload)[2:-1]
    print("Received -> Topic:",msg.topic,"Data",post)
    
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect(broker,port)
# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
client.loop_forever()
