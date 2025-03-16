#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_openvino.sh && bash install_openvino.sh ; 

#
echo "deb https://apt.repos.intel.com/openvino/2021 all main" | sudo tee /etc/apt/sources.list.d/intel-openvino-2021.list ;
wget https://apt.repos.intel.com/openvino/2021/GPG-PUB-KEY-INTEL-OPENVINO-2021 ;
sudo apt-key add GPG-PUB-KEY-INTEL-OPENVINO-2021  ;
sudo apt update ;
apt-cache search openvino ;
sudo apt-cache search intel-openvino-runtime-ubuntu20 ;

#
sudo apt install -y intel-openvino-dev-ubuntu20-2021.4.582 ;
