import paho.mqtt.client as paho
import random 
import json

broker = "broker.hivemq.com"
port=1883

#create function for callback
def on_publish(client,userdata,result): 
    print("data published",userdata,"\n")
    pass

#create client object
client1= paho.Client("publisherMongoOn-Off")

#assign function to callback
client1.on_publish = on_publish

#establish connection
client1.connect(broker,port)

#publish
print("On/Off arduino")
data=input("On -> 1\nOff -> 0\nInput: ")
ret= client1.publish("analytica/arduino",data)
print(ret)