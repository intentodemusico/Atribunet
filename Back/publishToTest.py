import paho.mqtt.client as paho
import random 
from time import sleep
import json

broker = "broker.hivemq.com"
port=1883

#create function for callback
def on_publish(client,userdata,result): 
    print("data published",userdata,"\n")
    pass

#create client object
client1= paho.Client("publisherTest")

#assign function to callback
client1.on_publish = on_publish

#establish connection
client1.connect(broker,port)

#publish
while(True):
	data={"node":"TEST_DO-NOT-USE","timestamp":"00000000000","data":str(random.random())}
	data_out=json.dumps(data)
	ret= client1.publish("analytica/data",data_out)
	print(ret)
	sleep(5)
