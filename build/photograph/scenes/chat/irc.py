#!/usr/bin/env python3
"""The chat scene's IRC server: a scripted stand-in on 127.0.0.1:6667.

It speaks just enough IRC for one client to connect as "reader", join the
channels in CHANNELS, and receive a fixed conversation with fixed server-time
tags, so every take shows the same messages and timestamps. No network, no
real users. The conversation has a join, a quit, a /me action, a link, inline
code, mIRC colors, a message from the reader, a mention in another channel,
and an unread message, so a client's theme shows each of its message colors.
"""
import socket

HOST, PORT, NICK, SERVER = "127.0.0.1", 6667, "reader", "irc.inglenook.invalid"
NAMES = "@maple +wren hazel oak reader"
TOPIC = "A warm corner for tea and code | notes: https://example.org/inglenook"
# (channel, minute, sender, line). Sender None is a raw command from the server.
CHANNELS = ["#inglenook", "#garden", "#tea"]
SCRIPT = [
    ("#inglenook", 28, "maple", "morning all, the kettle is on"),
    ("#inglenook", 29, "wren", "morning! did anyone try the new build?"),
    ("#inglenook", 30, None, ":fern!fern@cabin.invalid JOIN #inglenook"),
    ("#inglenook", 31, "fern", "the night variant is lovely after sunset"),
    ("#inglenook", 32, "maple", "\x01ACTION pours another cup\x01"),
    ("#inglenook", 33, "hazel", "notes from yesterday are at https://example.org/inglenook/notes"),
    ("#inglenook", 34, "wren", "run \x11pwsh build/check.ps1\x11 before you push"),
    ("#inglenook", 35, "reader", "it passes now, thanks"),
    ("#inglenook", 36, "fern", "today's tea: \x0303sencha\x03, \x0307rooibos\x03, \x0306earl grey\x03, \x0302blue lady\x03"),
    ("#inglenook", 37, None, ":oak!oak@cabin.invalid QUIT :gone to chop wood"),
    ("#inglenook", 38, "hazel", "see you at the fire tonight"),
    ("#garden", 39, "fern", "the tomatoes are finally red"),
    ("#tea", 40, "maple", "reader, the oolong you asked about came in"),
]


def tagged(minute, line):
    return f"@time=2026-06-01T09:{minute:02d}:00.000Z {line}"


def main():
    srv = socket.socket()
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((HOST, PORT))
    srv.listen(1)
    while True:
        conn, _ = srv.accept()
        serve(conn)


def serve(conn):
    def send(line):
        conn.sendall((line + "\r\n").encode())

    me = f"{NICK}!{NICK}@cabin.invalid"
    joined, buf = set(), b""
    while True:
        data = conn.recv(4096)
        if not data:
            conn.close()
            return
        buf += data
        while b"\r\n" in buf or b"\n" in buf:
            raw, _, buf = buf.partition(b"\n")
            line = raw.decode(errors="replace").strip("\r")
            parts = line.split(" ")
            cmd = parts[0].upper()
            if cmd == "CAP" and len(parts) > 1 and parts[1].upper() == "LS":
                send(f":{SERVER} CAP * LS :server-time")
            elif cmd == "CAP" and len(parts) > 1 and parts[1].upper() == "REQ":
                send(f":{SERVER} CAP {NICK} ACK {' '.join(parts[2:])}")
            elif cmd == "USER":
                send(f":{SERVER} 001 {NICK} :Welcome to the inglenook, {NICK}")
                send(f":{SERVER} 002 {NICK} :Your host is {SERVER}")
                send(f":{SERVER} 003 {NICK} :This server was lit in June")
                send(f":{SERVER} 004 {NICK} {SERVER} scene o o")
                send(f":{SERVER} 005 {NICK} CHANTYPES=# PREFIX=(ov)@+ NETWORK=Inglenook :are supported")
                send(f":{SERVER} 375 {NICK} :- {SERVER} message of the day")
                send(f":{SERVER} 372 {NICK} :- Pull up a bench by the fire.")
                send(f":{SERVER} 376 {NICK} :End of message of the day")
            elif cmd == "PING":
                send(f":{SERVER} PONG {SERVER} {' '.join(parts[1:])}")
            elif cmd == "JOIN" and len(parts) > 1:
                for chan in parts[1].split(","):
                    if chan not in CHANNELS or chan in joined:
                        continue
                    joined.add(chan)
                    send(f":{me} JOIN {chan}")
                    send(f":{SERVER} 332 {NICK} {chan} :{TOPIC if chan == '#inglenook' else 'Pull up a bench'}")
                    send(f":{SERVER} 353 {NICK} = {chan} :{NAMES}")
                    send(f":{SERVER} 366 {NICK} {chan} :End of names")
                if joined == set(CHANNELS):
                    for chan, minute, who, text in SCRIPT:
                        if who is None:
                            send(tagged(minute, text))
                        else:
                            send(tagged(minute, f":{who}!{who}@cabin.invalid PRIVMSG {chan} :{text}"))


if __name__ == "__main__":
    main()
