#!/bin/bash

{
set -x

sudo echo 'root:root' | sudo chpasswd
sudo echo 'splunk:splunk' | sudo chpasswd
sudo echo 'ansible:ansible' | sudo chpasswd
sudo apt-get update
sudo apt-get install -y openssh-server mlocate net-tools iproute2
sudo updatedb
sleep 5
sudo sed -i.bak '/#PermitRootLogin prohibit-password/a PermitRootLogin yes' /etc/ssh/sshd_config
sudo service ssh start


# sudo sed -i.bak '/ansible:\/bin\/sh/a ansible:x:999:999::\/home\/ansible:\/bin\/bash' /etc/passwd
sudo sed -i.bak 's/ansible:\/bin\/sh/ansible:\/bin\/sh:\/bin\/bash/g' /etc/passwd


# sudo sed -i.bak '$ a export SPLUNK_HOME=/opt/splunk' /etc/profile
sleep 3
sudo cat /austin/splunk-profile-template | sudo tee -a /etc/profile
sleep 3
source /etc/profile
sleep 3
sudo cat /austin/splunk-profile-template | sudo tee -a /root/.bashrc
sleep 3
source /root/.bashrc
sleep 3
sudo cat /austin/splunk-profile-template | sudo tee -a /home/ansible/.bashrc
sleep 3
source /home/ansible/.bashrc
# source /opt/splunk/bin/setSplunkEnv


sleep 15
sudo /opt/splunk/bin/splunk add user splunk -password P@ssw0rd -role power -force-change-pass false -auth admin:P@ssw0rd


# Set local-index store and forward
sleep 3
sudo /opt/splunk/bin/splunk enable local-index -auth admin:P@ssw0rd

sleep 3
sudo /opt/splunk/bin/splunk enable app SplunkForwarder -auth admin:P@ssw0rd

# You can replace host to any indexer available
sleep 3
sudo /opt/splunk/bin/splunk add forward-server splunk7.3-indexer1:9997 -auth admin:P@ssw0rd


sleep 2
sudo updatedb


sleep 10
sudo /opt/splunk/bin/splunk enable boot-start -auth admin:P@ssw0rd


# Restart splunk
sleep 2
sudo /opt/splunk/bin/splunk restart


set +x
} 2>&1 | tee init_script_$(hostname)_$(date +%F).log