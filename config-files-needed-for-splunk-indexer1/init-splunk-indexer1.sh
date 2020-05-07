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


sleep 2
sudo mkdir /opt/splunk/etc/system/local
sleep 2
# Add new sourcetype as "db_audit" with csv sourcetype under props.conf
sudo cp -v /austin/austin-system-local-props.conf /opt/splunk/etc/system/local/props.conf
sleep 2
sudo ls -l /opt/splunk/etc/system/local
sleep 2
sudo cat /opt/splunk/etc/system/local/props.conf


# Customize - to add indexes
# /opt/splunk/etc/apps/search/local --- will be in search app
# /opt/splunk/etc/system/local ---- will be in system app --- wchih is the default main index located
sleep 2
sudo cp -v /austin/indexes.conf /opt/splunk/etc/system/local/indexes.conf
sleep 2
sudo /opt/splunk/bin/splunk restart


sleep 20
splunk add oneshot /austin/db_audit_30DAY.csv -hostname database -sourcetype db_audit -index splunk_sample_log_index -auth admin:P@ssw0rd

sleep 5
splunk add oneshot /austin/access_30DAY.log -hostname web-applicaion -index splunk_sample_log_index -auth admin:P@ssw0rd

sleep 5
splunk add oneshot /austin/linux_s_30DAY.log -sourcetype linux_secure -hostname web-server -index splunk_sample_log_index -auth admin:P@ssw0rd


sleep 5
sudo /opt/splunk/bin/splunk install app /austin/eventgen_652.tgz -auth admin:P@ssw0rd
sleep 5
sudo mkdir /opt/splunk/etc/apps/SA-Eventgen/local
sleep 2
sudo cp -v /austin/local-austin-test-event-gen/* /opt/splunk/etc/apps/SA-Eventgen/local/
sleep 2
sudo ls -l /opt/splunk/etc/apps/SA-Eventgen/local/
sleep 2
sudo mv -v /opt/splunk/etc/apps/SA-Eventgen/local/eventgen.conf /opt/splunk/etc/apps/SA-Eventgen/local/austin-eventgen.conf
sleep 2
sudo cp -v /austin/youtube_sample_eventgen/eventgen.conf /opt/splunk/etc/apps/SA-Eventgen/local/
sleep 2
sudo ls -l /opt/splunk/etc/apps/SA-Eventgen/local/
sleep 2
sudo cat /opt/splunk/etc/apps/SA-Eventgen/local/eventgen.conf
sleep 2
sudo cp -v /austin/youtube_sample_eventgen/seed_data.csv /opt/splunk/etc/apps/SA-Eventgen/samples/
sleep 2
sudo mkdir /opt/splunk/etc/apps/search/local
sudo mkdir /opt/splunk/etc/apps/search/local/data
sudo mkdir /opt/splunk/etc/apps/search/local/data/ui
sudo mkdir /opt/splunk/etc/apps/search/local/data/ui/views
sleep 2
sudo cp -v /austin/austin-search-local-data-ui-views-test.xml /opt/splunk/etc/apps/search/local/data/ui/views/test.xml
# Below to add new lookup table from csv file
sleep 2
sudo cp -v /austin/products.csv /opt/splunk/etc/apps/search/lookups/products.csv
sleep 2
sudo cp -v /austin/prices.csv /opt/splunk/etc/apps/search/lookups/prices.csv
sleep 2
sudo cp -v /austin/vendors.csv /opt/splunk/etc/apps/search/lookups/vendors.csv
# Below to add new lookup defination
sleep 2
sudo cp -v /austin/austin-search-local-transforms.conf /opt/splunk/etc/apps/search/local/transforms.conf
# Below to add new auto lookup
sleep 2
sudo cp -v /austin/austin-search-local-props.conf /opt/splunk/etc/apps/search/local/props.conf


# To activate deployment server - put in app into the deployment-apps folder
sleep 2
sudo tar -xvzf /austin/splunk-add-on-for-unix-and-linux_700.tgz  -C /opt/splunk/etc/deployment-apps
sleep 2
sudo mkdir /opt/splunk/etc/deployment-apps/Splunk_TA_nix/local
sleep 2
sudo cp -v /austin/deployment_apps_inputs.conf /opt/splunk/etc/deployment-apps/Splunk_TA_nix/local/inputs.conf
sleep 2
sudo cp -v /austin/deployment_apps_outputs.conf /opt/splunk/etc/deployment-apps/Splunk_TA_nix/local/outputs.conf
sleep 7
sudo tar -xvzf /austin/splunk-add-on-for-microsoft-windows_700.tgz  -C /opt/splunk/etc/deployment-apps
sleep 7
sudo chown -R splunk /opt/splunk/etc/deployment-apps/


# Deploy serverclass
sleep 2
sudo cp -v /austin/serverclass.conf /opt/splunk/etc/system/local/serverclass.conf
sleep 2
sudo /opt/splunk/bin/splunk reload deploy-server -auth admin:P@ssw0rd
sleep 2
sudo /opt/splunk/bin/splunk list deploy-clients -auth admin:P@ssw0rd


sleep 2
sudo updatedb


sleep 10
sudo /opt/splunk/bin/splunk enable boot-start -auth admin:P@ssw0rd


# Restart splunk
sleep 2
sudo /opt/splunk/bin/splunk restart


set +x
} 2>&1 | tee init_script_$(hostname)_$(date +%F).log