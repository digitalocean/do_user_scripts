#!/usr/bin/env bash
PUBLIC_IPV4="$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)"

mkdir -p /etc/systemd/system/sshd.socket.d

cat >/etc/systemd/system/sshd.socket.d/10-sshd-listen.conf <<EOF
[Socket]
ListenStream=
ListenStream=${PUBLIC_IPV4}:22
FreeBind=true
EOF

systemctl daemon-reload && systemctl restart sshd.socket

systemctl enable sshd.socket
