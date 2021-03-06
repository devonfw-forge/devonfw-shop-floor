#!/bin/sh

############################################################################
# Copyright 2015-2018 Capgemini SE.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
############################################################################

# Draw Logo

echo -e " 
         _      __ _  _   _  __     _                          _             
      __| |___ / _| || | | |/ /   _| |__   ___ _ __ _ __   ___| |_ ___  ___  
     / _\` / __| |_| || |_| ' / | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __| 
    | (_| \__ \  _|__   _| . \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \ 
     \__,_|___/_|    |_| |_|\_\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/ 
    
    Version 2.0
"

# Kill kubectl process
kill -9 $(lsof -i tcp:443 | grep kubectl | cut -d " " -f 4)

# to stop the script if something fail.
set -e

# Uninstall
sudo kubeadm reset

sudo yum remove -y kubectl

sudo yum remove -y kubelet

echo -e "\nDeleting file system resources..."

sudo rm -rf /etc/kubernetes*
sudo rm -f /etc/yum.repos.d/kubernetes*
sudo rm -f /etc/sysctl.d/k8s.conf*
sudo rm -f /usr/bin/kubeadm
sudo rm -f /usr/bin/kubectl
sudo rm -f /usr/bin/kubelet
sudo rm -rf $HOME/.kube
sudo rm -rf /etc/systemd/system/kubelet.service.d/
# sudo rm -f /etc/systemd/system/multi-user.target.wants/kubelet.service
# sudo rm -f /usr/lib/systemd/system/kubelet.service

sudo systemctl stop kubepods*.slice
sudo systemctl reset-failed kubelet

echo -e "\nDeleting docker images..."

sudo docker rmi -f $(docker images | grep -E 'gcr|quay.io|docker.io' | awk '{print $3}')

sudo sed -i '/ swap / s/^#\(.*\)$/\1/g' /etc/fstab
sudo swapon -a

case $(getenforce) in
    "Disabled" ) echo "We do not want to change your configuration but take care: SELINUX is disabled";;
    "Enforcing" ) ;;
    * ) sudo setenforce 1;;
esac

case $(grep "^SELINUX=" /etc/sysconfig/selinux) in
    "SELINUX=disabled" ) echo "We do not want to change your configuration but take care: SELINUX is disabled in /etc/sysconfig/selinux";;
    "SELINUX=enforcing" ) ;;
    "SELINUX=permissive" ) sudo sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/sysconfig/selinux;;
esac

read -n1 -r -p "Press any key to close..." key
