# Runs a terminal program in a pseudo-terminal of the same size, passes its screen through,
# and types the given keys once it has drawn and gone quiet for a second, so a scene can
# stage a selection the way a reader makes one. Usage: keys.py <keys> <command> [args...]
import fcntl, os, select, signal, subprocess, sys, termios, time, tty

keys, cmd = sys.argv[1].encode(), sys.argv[2:]
master, slave = os.openpty()


def resize(*_):
    fcntl.ioctl(master, termios.TIOCSWINSZ, fcntl.ioctl(0, termios.TIOCGWINSZ, b'\0' * 8))


def write_all(fd, data):
    while data:
        data = data[os.write(fd, data):]


resize()
signal.signal(signal.SIGWINCH, resize)
child = subprocess.Popen(cmd, stdin=slave, stdout=slave, stderr=slave, start_new_session=True,
                         preexec_fn=lambda: fcntl.ioctl(0, termios.TIOCSCTTY, 0))
os.close(slave)
saved = termios.tcgetattr(0)
tty.setraw(0)
sent, last = False, None
try:
    while child.poll() is None:
        ready, _, _ = select.select([master, 0], [], [], 0.2)
        if master in ready:
            try:
                data = os.read(master, 65536)
            except OSError:
                break
            if not data:
                break
            write_all(1, data)
            last = time.monotonic()
        if 0 in ready:
            write_all(master, os.read(0, 1024))
        if not sent and last is not None and time.monotonic() - last > 1.0:
            write_all(master, keys)
            sent = True
finally:
    termios.tcsetattr(0, termios.TCSADRAIN, saved)
