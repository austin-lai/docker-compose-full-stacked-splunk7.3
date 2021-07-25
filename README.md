<!-- 

Started 25032020
Updated 06032020
Updated 25072021

-->

# docker-compose-full-stacked-splunk7.3

Spin up splunk with docker-compose

<br />

- You can validate your docker-compose with "docker-compose config"
  - ` docker-compose config -f full-stack-splunk-docker-compose.yml `

- To start the full stack
  - ` docker-compose -f full-stack-splunk-docker-compose.yml up -d `

- To check logs of container
  - ` docker logs -f splunk7.3-indexer `
  - ` docker logs -f splunk7.3-forwarder `

- After splunk docker run
  - ` docker exec -u root splunk7.3-indexer bash -c 'cd /austin; ./init-splunk-indexer.sh' `
  - ` docker exec -u root splunk7.3-indexer bash -c 'service ssh start' `
  - ` docker exec -u root splunk7.3-forwarder bash -c 'cd /austin; ./init-splunk-forwarder.sh' `
  - ` docker exec -u root splunk7.3-forwarder bash -c 'service ssh start' `


- If you want to Destroy or stop or remove docker
  - ` docker-compose -f full-stack-splunk-docker-compose.yml down -v --remove-orphans `




# check which license group is active
sudo /opt/splunk/bin/splunk list licenser-groups -auth admin:P@ssw0rd

# switch to free license
sudo /opt/splunk/bin/splunk edit licenser-groups Free -is_active 1 -auth admin:P@ssw0rd

sudo /opt/splunk/bin/splunk restart



sudo docker run --rm -dit -P -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=P@ssw0rd" --hostname splunk7.3 --name splunk7.3 store/splunk/splunk:7.3.0


docker pull store/splunk/splunk:7.3.0


sudo /opt/splunk/bin/splunk cmd btool props list | grep csv
sudo /opt/splunk/bin/splunk cmd btool props list --debug | grep csv

splunk btool check


========================================================================================================

You can use command below to extract default config from splunk
---  docker run --rm -it -P -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=P@ssw0rd" --hostname splunk7.3 --name splunk7.3 store/splunk/splunk:7.3.0 create-defaults > default.yml


Make a init script -- init.sh
#!/bin/bash
sudo echo 'root:root' | sudo chpasswd
sudo apt update
sudo apt-get install -y openssh-server
sudo sed -i '/#PermitRootLogin prohibit-password/a PermitRootLogin yes' /etc/ssh/sshd_config
sudo service ssh start
--- And with whatever you want to do


Make a Dockerfile
--FROM splunk images as base "AS" new-images-name
--Label maintainer="Austin.Lai"
--COPY the scipt to install ssh and change sshd config and change root password && whatever thing you want to do
--RUN the script



Make a docker-compose.yml


Spin up splunk with docker-compose
--- you can validate your docker-compose with "docker-compose config"
--- docker-compose up -d
--- docker logs -f images-name

After splunk docker run
--- docker exec -it splunk7.3 bash
--- docker exec -it -u root splunk7.3-indexer /bin/bash
--- docker exec -u root splunk7.3-indexer bash -c 'cd /austin; ./init.sh'
--- docker exec splunk7.3-indexer bash -c 'sudo service ssh start'


Destroy or stop or remove docker
--- docker rm -vf splunk7.3
--- docker-compose down


sudo /opt/splunk/bin/splunk cmd btool props list | grep csv
sudo /opt/splunk/bin/splunk cmd btool props list --debug | grep csv

splunk btool check
