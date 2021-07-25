<!-- 

Started 25032020
Updated 06032020
Updated 25072021

-->

# docker-compose-full-stacked-splunk7.3

Note: This docker-compose, information build on the year 2020 and it's built for isolated lab environment, hence some command or information might not up-to-date, howver, you may take it as a reference

Spin up splunk with docker-compose

<br />

## Sample docker compose file included as below information or components

- ` full-stack-splunk-docker-compose.yml ` --- using docker-compose version 3.7

- It contained
    - A network using ` bridge ` with the name ` splunk-dhcp-server `
        - subnet under 172.16.238.0/24
    - A service with
        - ` splunk7.3-indexer1 ` - Enable by default
        - ` splunk7.3-indexer2 ` - Disable by default
        - ` splunk7.3-heavy-forwarder1 ` - Disable by default
        - ` splunk7.3-heavy-forwarder2 ` - Disable by default
        - ` splunk7.3-forwarder1 ` - Disable by default
        - ` splunk7.3-forwarder2 ` - Disable by default

<br />

## You can validate docker-compose with "docker-compose config"

- ` docker-compose config -f full-stack-splunk-docker-compose.yml `

<br />

## To start the full stack

- ` docker-compose -f full-stack-splunk-docker-compose.yml up -d `
- Remember to enable other components in ` full-stack-splunk-docker-compose.yml `

<br />

## Sample command - to check logs of container

- ` docker logs -f splunk7.3-indexer `
- ` docker logs -f splunk7.3-forwarder `

<br />

## After splunk docker run, execute below command for each components --- sample command shown below

- Indexer --- to enable ssh and all the configuration needed, you can refer to the folder  "config-file-needed-for-splunk-indexer1" > " init-splunk-indexer.sh "
    - ` docker exec -u root splunk7.3-indexer1 bash -c 'cd /austin; ./init-splunk-indexer1.sh' `
    - ` docker exec -u root splunk7.3-indexer bash -c 'service ssh start' `

- Heavy Forwarder --- to enable ssh and all the configuration needed, you can refer to the folder  "config-file-needed-for-splunk-heavy-forwarder1" > " init-splunk-heavy-forwarder1.sh "
- ` docker exec -u root splunk7.3-heavy-forwarder1 bash -c 'cd /austin; ./init-splunk-heavy-forwarder1.sh' `
- ` docker exec -u root splunk7.3-heavy-forwarder1 bash -c 'service ssh start' `

- Universal Forwarder --- to enable ssh and all the configuration needed, you can refer to the folder  "config-file-needed-for-splunk-forwarder1" > " init-splunk-forwarder1.sh "
- ` docker exec -u root splunk7.3-forwarder1 bash -c 'cd /austin; ./init-splunk-forwarder1.sh' `
- ` docker exec -u root splunk7.3-forwarder1 bash -c 'service ssh start' `

<br />

## If you want to Destroy or stop or remove docker

- ` docker-compose -f full-stack-splunk-docker-compose.yml down -v --remove-orphans `

<br />

## Check which license group is active

```bash
sudo /opt/splunk/bin/splunk list licenser-groups -auth admin:P@ssw0rd
```

<br />

## Switch to free license

```
sudo /opt/splunk/bin/splunk edit licenser-groups Free -is_active 1 -auth admin:P@ssw0rd

sudo /opt/splunk/bin/splunk restart
```

<br />

## You can use command below to extract default config from splunk

```
docker run --rm -it -P -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=P@ssw0rd" --hostname splunk7.3 --name splunk7.3 store/splunk/splunk:7.3.0 create-defaults > default.yml
```

<br />

## Create own init script -- init.sh

You can create your own init script and replace it in each component folder

```bash
#!/bin/bash
sudo echo 'root:root' | sudo chpasswd
sudo apt update
sudo apt-get install -y openssh-server
sudo sed -i '/#PermitRootLogin prohibit-password/a PermitRootLogin yes' /etc/ssh/sshd_config
sudo service ssh start
--- And with whatever you want to do
```

<br />

## Make a Dockerfile - if you plan to build your own version

```dockerfile
FROM splunk images as base "AS" new-images-name
Label maintainer="Austin.Lai"
COPY ```the scipt to install ssh and change sshd config and change root password && whatever thing you want to do```
RUN the script
```

<br />

## Pull official splunk docker

```
docker pull store/splunk/splunk:7.3.0
```

<br />

## Splunk command - btool

```bash
sudo /opt/splunk/bin/splunk cmd btool props list | grep csv

sudo /opt/splunk/bin/splunk cmd btool props list --debug | grep csv

splunk btool check
```

