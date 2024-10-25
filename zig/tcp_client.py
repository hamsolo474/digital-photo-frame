#! /bin/python

import sys
import socket

HOST = "127.0.0.1"  # The server's hostname or IP address
PORT = 4744  # The port used by the server
msg = bytes(sys.argv[1], "utf-8")

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    s.sendall(msg)
#    data = s.recv(1024)

#print(f"Received {data!r}")
