import paho.mqtt.client as mqtt
import json
import socket
broker = "broker.hivemq.com"
port = 1883

HOST = '0.0.0.0'  # Standard loopback interface address (localhost)
PORT = 80		# Port to listen on (non-privileged ports are > 1023)

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
	print("Connected to MQTT broker, with result code "+str(rc))
	# Subscribing in on_connect() means that if we lose the connection and
	# reconnect then subscriptions will be renewed.
	#client.subscribe("$SYS/#")
	client.subscribe("analytica/data")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
	global conn
	post=str(msg.payload)[2:-1]
	print(msg.topic,post)
	conn.sendall(bytes(post, encoding='utf-8'))

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
	s.bind((HOST, PORT))
	s.listen()
	conn, addr = s.accept()
	with conn:
		print('Connected by', addr)
		data=""
		while data=="":
			data = conn.recv(1024)

		conn.sendall(b'Conecta2')
		print('Connected by', addr)
		client = mqtt.Client()
		client.on_connect = on_connect
		client.on_message = on_message
		client.connect(broker,port)
		client.loop_forever()
