#!/usr/bin/env bash
rm -f /etc/ssh/sshd_config

cat >/etc/ssh/sshd_config <<'EOF'
# Use most defaults for sshd configuration.
UsePrivilegeSeparation sandbox
Subsystem sftp internal-sftp
UseDNS no

PermitRootLogin no
AllowUsers core
AuthenticationMethods publickey
EOF

chmod 0600 /etc/ssh/sshd_config
