# The machine btop watches in the CLI/TUI scene (see stage.sh): a small, fixed /proc
# and /sys that proot lays over the real ones, so every take shows the same numbers.
# The busy processes' stat files are FIFOs: each read gets that process's next sample.
# Each pass btop makes over the processes (counted by one of those reads) moves the
# machine one sample on and rewrites /proc/stat, so the graphs move with btop's
# updates, whatever their timing. After PASSES passes /proc/stat becomes a FIFO that
# nothing writes: btop's next read waits for good, and its screen stays as it is for
# the grab. The graphs are full by then, so the reads btop makes while it starts never
# show.
# Usage: python3 machine.py <dir>. Builds <dir>/proc, <dir>/sys and <dir>/passwd,
# touches <dir>/ready, then serves the FIFOs until killed.
import glob, math, os, sys, threading, time

root = os.path.abspath(sys.argv[1])
proc, sysfs = os.path.join(root, 'proc'), os.path.join(root, 'sys')
CORES = 4       # btop is held to one real CPU (stage.sh), so these decide the count
TICKS = 100     # clock ticks each core adds per sample
PASSES = 170    # btop's passes over the processes before the screen holds still
SENTINEL = 902  # the busy process whose reads count the passes
passes = 0


def put(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(text)


def fifo(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    os.mkfifo(path)


def busy(n, c):
    # Ticks of core c's TICKS spent working in sample n: a slow swell with a quicker ripple.
    v = 34 + 22 * math.sin(n * 0.11 + c * 1.7) + 9 * math.sin(n * 0.37 + c * 0.6)
    return max(3, min(96, int(round(v))))


def stat(n):
    cores = []
    for c in range(CORES):
        b = sum(busy(k, c) for k in range(n + 1))
        user, system = b * 3 // 4, b - b * 3 // 4
        idle = (n + 1) * TICKS - b
        cores.append((user, 0, system, idle, 0, 0, 0, 0, 0, 0))
    total = [sum(col) for col in zip(*cores)]
    lines = ['cpu  ' + ' '.join(map(str, total))]
    lines += ['cpu%d %s' % (c, ' '.join(map(str, t))) for c, t in enumerate(cores)]
    lines += ['intr 0', 'ctxt 0', 'btime 1763700000', 'processes 4242', 'procs_running 2', 'procs_blocked 0', '']
    return '\n'.join(lines)


# pid, ppid, user id, name, command line, threads, resident MiB, CPU percent (0: idle)
PROCS = [
    (1, 0, 0, 'systemd', '/sbin/init splash', 1, 13, 0),
    (412, 1, 0, 'systemd-journal', '/usr/lib/systemd/systemd-journald', 1, 22, 0),
    (733, 1, 0, 'NetworkManager', '/usr/sbin/NetworkManager --no-daemon', 3, 19, 0),
    (902, 1, 0, 'Xorg', '/usr/lib/xorg/Xorg :0 -seat seat0 -nolisten tcp', 4, 96, 4),
    (1184, 1, 1000, 'cinnamon', 'cinnamon --replace', 12, 318, 3),
    (1420, 1184, 1000, 'gnome-terminal-', '/usr/libexec/gnome-terminal-server', 5, 61, 1),
    (1437, 1420, 1000, 'bash', 'bash', 1, 5, 0),
    (2051, 1437, 1000, 'pwsh', 'pwsh build/check.ps1', 18, 212, 31),
    (2210, 1184, 1000, 'firefox', '/usr/lib/firefox/firefox', 64, 742, 9),
    (2265, 2210, 1000, 'Isolated Web Co', '/usr/lib/firefox/firefox -contentproc -isForBrowser', 27, 288, 5),
    (2390, 1184, 1000, 'code', '/usr/share/code/code .', 34, 405, 2),
    (2502, 1437, 1000, 'btop', 'btop', 1, 9, 1),
]


def pid_stat(pid, ppid, name, threads, rss_mib, utime):
    state = 'R' if utime else 'S'
    pages = rss_mib * 256
    return ('%d (%s) %s %d %d %d 34816 %d 4194304 0 0 0 0 %d %d 0 0 20 0 %d 0 %d %d %d '
            '18446744073709551615 1 1 0 0 0 0 0 0 0 0 0 0 17 0 0 0 0 0 0\n'
            % (pid, name, state, ppid, pid, pid, pid, utime * 3 // 4, utime - utime * 3 // 4,
               threads, 2000 + pid, pages * 4096 * 3, pages))


def build():
    put(os.path.join(proc, 'uptime'), '273851.40 1063112.25\n')
    put(os.path.join(proc, 'loadavg'), '1.18 0.94 0.71 2/412 2502\n')
    put(os.path.join(proc, 'meminfo'), ''.join('%-16s%8d kB\n' % kv for kv in [
        ('MemTotal:', 16303428), ('MemFree:', 5124360), ('MemAvailable:', 10288832),
        ('Buffers:', 412776), ('Cached:', 4670216), ('SwapCached:', 0), ('Shmem:', 352120),
        ('SReclaimable:', 301544), ('SwapTotal:', 4194300), ('SwapFree:', 3908220)]))
    put(os.path.join(proc, 'cpuinfo'), ''.join(
        'processor\t: %d\nvendor_id\t: GenuineIntel\nmodel name\t: Hearth 4-core\n'
        'cpu MHz\t\t: 2400.000\nphysical id\t: 0\ncore id\t\t: %d\ncpu cores\t: %d\n\n' % (c, c, CORES)
        for c in range(CORES)))
    put_stat(0)
    for pid, ppid, uid, name, cmd, threads, rss, cpu in PROCS:
        d = os.path.join(proc, str(pid))
        put(os.path.join(d, 'comm'), name + '\n')
        put(os.path.join(d, 'cmdline'), '\0'.join(cmd.split(' ')) + '\0')
        put(os.path.join(d, 'status'), 'Name:\t%s\nState:\tS (sleeping)\nPid:\t%d\nPPid:\t%d\nUid:\t%d\t%d\t%d\t%d\n'
            % (name, pid, ppid, uid, uid, uid, uid))
        put(os.path.join(d, 'statm'), '%d %d 0 0 0 0 0\n' % (rss * 768, rss * 256))
        if cpu:
            fifo(os.path.join(d, 'stat'))
        else:
            put(os.path.join(d, 'stat'), pid_stat(pid, ppid, name, threads, rss, 0))
    cpu = os.path.join(sysfs, 'devices', 'system', 'cpu')
    put(os.path.join(cpu, 'online'), '0-%d\n' % (CORES - 1))
    for c in range(CORES):
        put(os.path.join(cpu, 'cpufreq', 'policy%d' % c, 'scaling_cur_freq'), '2400000\n')
    hw = os.path.join(sysfs, 'class', 'hwmon', 'hwmon0')
    put(os.path.join(hw, 'name'), 'coretemp\n')
    temps = [('Package id 0', 54)] + [('Core %d' % c, t) for c, t in enumerate([52, 55, 51, 53])]
    for i, (label, temp) in enumerate(temps, 1):
        put(os.path.join(hw, 'temp%d_label' % i), label + '\n')
        put(os.path.join(hw, 'temp%d_input' % i), '%d000\n' % temp)
        put(os.path.join(hw, 'temp%d_max' % i), '84000\n')
        put(os.path.join(hw, 'temp%d_crit' % i), '100000\n')
    for iface in ('lo', 'eth0'):
        put(os.path.join(sysfs, 'class', 'net', iface, 'statistics', 'rx_bytes'), '0\n')
        put(os.path.join(sysfs, 'class', 'net', iface, 'statistics', 'tx_bytes'), '0\n')
    put(os.path.join(root, 'passwd'), 'root:x:0:0:root:/root:/bin/bash\nhearth:x:1000:1000:Hearth:/home/hearth:/bin/bash\n')


reader = None


def held(path):
    # True while btop still has the FIFO open: it has not finished reading.
    global reader
    if reader is None:
        for comm in glob.glob('/proc/[0-9]*/comm'):
            try:
                with open(comm) as f:
                    if f.read().strip() == 'btop':
                        reader = os.path.dirname(comm)
                        break
            except OSError:
                pass
        if reader is None:
            return False
    try:
        fds = os.listdir(reader + '/fd')
    except OSError:
        return False
    for fd in fds:
        try:
            if os.readlink(reader + '/fd/' + fd) == path:
                return True
        except OSError:
            pass
    return False


def write_one(path, sample):
    fd = os.open(path, os.O_WRONLY)  # waits for btop to open it
    text = sample()  # made now, not before the wait: a pass may end while it waits
    data = text.encode()
    while data:
        data = data[os.write(fd, data):]
    os.close(fd)


def wait_closed(path):
    # One sample per read: the next waits until btop has closed this one.
    time.sleep(0.02)
    while held(path):
        time.sleep(0.01)


def put_stat(n):
    # Replaced whole, so a read sees one sample or the next, never a mix.
    path = os.path.join(proc, 'stat')
    if n < PASSES:
        put(path + '.new', stat(n))
    else:
        os.mkfifo(path + '.new')
    os.replace(path + '.new', path)


def serve_pid(path, pid):
    global passes
    _, ppid, _, name, _, threads, rss, cpu = next(p for p in PROCS if p[0] == pid)
    per = CORES * TICKS / 100.0  # ticks of one percent of the machine per pass
    used = 0
    for n in range(PASSES + 5):
        used += int(round(per * cpu * (1 + 0.35 * math.sin(n * 0.29 + pid))))
        write_one(path, lambda: pid_stat(pid, ppid, name, threads, rss, used))
        if pid == SENTINEL:
            # btop read /proc/stat before the processes, so the next read is the next update's.
            passes = n + 1
            put_stat(passes)
        wait_closed(path)


build()
open(os.path.join(root, 'ready'), 'w').close()
threads = [threading.Thread(target=serve_pid, args=(os.path.join(proc, str(p[0]), 'stat'), p[0]), daemon=True)
            for p in PROCS if p[7]]
for t in threads:
    t.start()
for t in threads:
    t.join()
time.sleep(1e9)
