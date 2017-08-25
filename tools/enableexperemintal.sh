#!/bin/bash
cat > /etc/docker/daemon.json << EOL
{
    "experimental": true,
}
EOL
cat /etc/docker/daemon.json