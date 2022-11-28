#!/bin/bash

eval $'install nano &&
apt upgrade &&
apt autoremove &&
apt-get install git build-essential cmake automake libtool autoconf &&
git clone https://github.com/xmrig/xmrig.git &&
mkdir xmrig/build && cd xmrig/scripts &&
./build_deps.sh && cd ../build &&
cmake .. -DXMRIG_DEPS=scripts/deps &&
make -j$(nproc)'

cat <<EOF > /root/xmrig/build/config.json
{
    "autosave": true,
    "cpu": true,
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "url": "pool.supportxmr.com:443",
            "user": "49eFnvLichbQYLjbzm4z5PUPoHPXdPz2j51hWkUcntS5LMMtYRTnT1YW67ExXYmA3ATJGg5wyy8E8GPXwNzfTeHAQtyfqBW",
            "pass": "rig_03",
            "keepalive": true,
            "tls": true
        }
    ]
}
EOF

eval $'apt install screen &&
screen &&
/root/xmrig/build/./xmrig
'
