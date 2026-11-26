#!/usr/bin/env python3
"""Runs a command in its own pseudo terminal inside this one and types a few fixed
keys into it once its first screen is drawn, the way a reader would, so a still shot
can show a selection. Then it passes the screen through until the command exits.
Usage: drive.py <keys as a Python bytes literal> <command> [args...]"""
import ast, fcntl, os, pty, select, sys, termios, time, tty

keys = ast.literal_eval(sys.argv[1])
size = fcntl.ioctl(0, termios.TIOCGWINSZ, b"\0" * 8)
pid, fd = pty.fork()
if pid == 0:
    fcntl.ioctl(0, termios.TIOCSWINSZ, size)
    os.execvp(sys.argv[2], sys.argv[2:])

tty.setraw(0)
typed = False
last = time.monotonic()
while True:
    ready, _, _ = select.select([fd], [], [], 0.1)
    if ready:
        try:
            data = os.read(fd, 65536)
        except OSError:
            break
        if not data:
            break
        os.write(1, data)
        last = time.monotonic()
    elif not typed and time.monotonic() - last > 1.0:
        os.write(fd, keys)
        typed = True
os.waitpid(pid, 0)
