#!/bin/bash

createconfig(){
cat <<EOF > /root/config.json
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
}

createservice(){
cat <<EOF > /etc/systemd/system/$1.service
[Unit]
Description=Run a script on server startup

[Service]
Type=oneshot
ExecStart=/root/$1.sh

[Install]
WantedBy=multi-user.target

EOF
}

sudo apt install -y nano
sudo apt update
sudo apt -y upgrade
sudo apt-get -y update
sudo apt autoremove
createconfig


cat <<EOF > /root/buf.sh
#!/bin/bash

cd root
sudo apt-get install -y git build-essential cmake automake libtool autoconf
git clone https://github.com/xmrig/xmrig.git
mkdir xmrig/build && cd xmrig/scripts
./build_deps.sh && cd ../build
cmake .. -DXMRIG_DEPS=scripts/deps
make -j$(nproc)
mv config.json xmrig/build/

EOF

chmod +x bufscript.sh
createservice "buf"
sudo systemctl enable bufservice

reboot
