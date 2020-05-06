import socket

HOST = '0.0.0.0'  # Standard loopback interface address (localhost)
PORT = 80        # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        data=""
        while True:
            if (data==""):
                data = conn.recv(1024)
            #if not data:
             #   break
            k=b'keso'
            conn.sendall(k)
            #s.sendall(b'Hello, world')