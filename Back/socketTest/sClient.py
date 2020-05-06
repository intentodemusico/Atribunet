import socket

HOST = 'atribunet3.bucaramanga.upb.edu.co'#10.154.12.44'#127.0.0.1'#207.248.81.158'  # The server's hostname or IP address
PORT = 80        # The port used by the server

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
	s.connect((HOST, PORT))
	s.sendall(b'olaprro')
	#while(True):

	data = s.recv(1024)
	while(data):
		print('Received', repr(data))
		data = s.recv(1024)