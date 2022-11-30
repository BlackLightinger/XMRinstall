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
            "user": "$1",
            "pass": "$2",
            "keepalive": true,
            "tls": true
        }
    ]
}
EOF
}

createservice(){
cat <<EOF > /etc/systemd/system/$1service.service
[Unit]
Description=Run a script on server startup

[Service]
Type=oneshot
ExecStart=/root/$1script.sh

[Install]
WantedBy=multi-user.target

EOF
}

createautorestartingminer(){
cat <<EOF > /root/restartingscript.sh
#!/bin/bash

screen -S work -X register c $'/root/xmrig/build/./xmrig'
screen -S work -X paste c

EOF
}

createSettingXMRMiner(){
cat <<EOF > /root/SettingXMRMiner.sh
#!/bin/bash

cd root
sudo apt-get install -y git build-essential cmake automake libtool autoconf
git clone https://github.com/xmrig/xmrig.git
mkdir xmrig/build && cd xmrig/scripts
./build_deps.sh && cd ../build
cmake .. -DXMRIG_DEPS=scripts/deps
make -j$(nproc)
mv /root/config.json /root/xmrig/build/

sudo apt install -y screen

sudo rm /root/bufscript.sh
sudo systemctl disable bufservice
sudo rm /root/etc/systemd/system/bufservice.service

sudo systemctl enable restartingservice

reboot

EOF
}

sudo apt install -y nano
sudo apt update
sudo apt -y upgrade
sudo apt-get -y update
sudo apt autoremove
createconfig "$1" "$2"
createSettingXMRMiner


cat <<EOF > /root/bufscript.sh
#!/bin/bash

cd root
chmod +x SettingXMRMiner.sh
./SettingXMRMiner.sh

EOF

chmod +x /root/bufscript.sh
createservice "buf"
sudo systemctl enable bufservice

createautorestartingminer
chmod +x /root/restartingscript.sh
createservice "restarting"


reboot
