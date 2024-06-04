#!/bin/bash
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset to default color

# Update system and install prerequisites
clear;
echo "${YELLOW}Update system and install prerequisites...${RESET}"
#sudo apt update
sudo apt install -y default-jdk wget
sleep 2

# Create Tomcat user and group
echo "${YELLOW}Create Tomcat user and group...${RESET}"
read -p "Enter the Tomcat for : " TOMCAT
sudo groupadd $TOMCAT
#sudo mkdir -p /opt/$TOMCAT
sudo useradd -s /bin/false -g $TOMCAT -d /opt/$TOMCAT $TOMCAT

# Download and install $TOMCAT
echo "${YELLOW}Tomcat Installation Script for Ubuntu...${RESET}"
cd /tmp
echo "Choose Tomcat version to install:"
echo "1. Tomcat 9.0.87"
echo "2. Tomcat 10.1.20"
echo "3. Tomcat 11.0.0-M16"

read -p "Enter your choice (1 or 2 or 3): " TOMCAT_VERSION_CHOICE

case $TOMCAT_VERSION_CHOICE in
  1)
    TOMCAT_VERSION="9.0.87"
#	wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz
	;;
  2)
    TOMCAT_VERSION="10.1.20"
#	wget https://downloads.apache.org/tomcat/tomcat-10/v10.1.20/bin/apache-tomcat-10.1.20.tar.gz
	;;
  3)
     TOMCAT_VERSION="11.0.0-M16"
#	wget https://downloads.apache.org/tomcat/tomcat-11/v11.0.0-M16/bin/apache-tomcat-11.0.0-M16.tar.gz
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Download the corresponding Tomcat version
TOMCAT_URL="https://downloads.apache.org/tomcat/tomcat-$(echo $TOMCAT_VERSION | cut -d'.' -f1)/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
wget "$TOMCAT_URL"

tar -xf apache-tomcat-$TOMCAT_VERSION.tar.gz
sudo mv apache-tomcat-$TOMCAT_VERSION /opt/$TOMCAT
sleep 2;

# Set permissions
echo "${YELLOW}Set permissions...${RESET}"
sudo chgrp -R $TOMCAT /opt/$TOMCAT
sudo chmod -R g+r /opt/$TOMCAT/conf
sudo chmod g+x /opt/$TOMCAT/conf
sudo chown -R $TOMCAT /opt/$TOMCAT/webapps/ /opt/$TOMCAT/work/ /opt/$TOMCAT/temp/ /opt/$TOMCAT/logs/
sleep 2

# Create a SystemD unit file
echo "${YELLOW}Create a SystemD unit file...${RESET}"
cat <<EOF | sudo tee /etc/systemd/system/$TOMCAT.service
[Unit]
Description=Apache $TOMCAT Web Application Container
After=network.target

[Service]
Type=forking
User=$TOMCAT
Group=$TOMCAT

Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="CATALINA_PID=/opt/$TOMCAT/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/$TOMCAT"
Environment="CATALINA_BASE=/opt/$TOMCAT"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/$TOMCAT/bin/startup.sh
ExecStop=/opt/$TOMCAT/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

sudo chmod +x /etc/systemd/system/$TOMCAT.service
sleep 2

# Reload SystemD and start $TOMCAT
echo "${YELLOW}Reload SystemD and start $TOMCAT...${RESET}"
sudo systemctl daemon-reload
sudo systemctl start $TOMCAT
sudo systemctl enable $TOMCAT
sudo systemctl status $TOMCAT | grep Active
sleep 2

# Install $tomcat Web Management Interface
echo "${YELLOW}Install $tomcat Web Management Interface...${RESET}"
sudo sed -i 's/<\/tomcat-users>/<user username="admin" password="!a568Pqt@111" roles="manager-gui,admin-gui"\/><\/tomcat-users>/' /opt/$TOMCAT/conf/tomcat-users.xml

# Deploy Manager app and Host Manager app
echo "${YELLOW}Deploy Manager app and Host Manager app...${RESET}"
## Step 1: Find the IP address
ip_address=$(hostname -I | awk '{print $1}')

if [ -z "$ip_address" ]; then
    echo "Failed to retrieve IP address."
    exit 1
else
    echo "IP address: $ip_address"
fi

## Step 2: Update context.xml for Manager application
manager_context="/opt/$TOMCAT/webapps/manager/META-INF/context.xml"
sudo sed -i ""127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|$ip_address" />" "$manager_context"

## Step 3: Update context.xml for Host Manager application
host_manager_context="/opt/$TOMCAT/webapps/host-manager/META-INF/context.xml"
sudo sed -i ""127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|$ip_address" />" "$host_manager_context"
sleep 2

#Create Port for $TOMCAT
read -p "Enter the Server Port (8005) for $TOMCAT : " SERVER_PORT
sudo sed -i ''s/<Server port="8005" /<Connector port="$SERVER_PORT" /'' /opt/$TOMCAT/conf/server.xml
sleep 2

read -p "Enter the Connector Port (8080) for $TOMCAT : " CONNECTOR_PORT
sudo sed -i "s/<Connector port="8080" /<Connector port="$CONNECTOR_PORT" /" /opt/$TOMCAT/conf/server.xml
sleep 2

sudo systemctl restart $TOMCAT
sudo systemctl status $TOMCAT | grep Active
sleep 2

# Allow port $Port
echo "${YELLOW}Allow port $TOMCAT_PORT..${RESET}"
sudo ufw allow $CONNECTOR_PORT
sudo systemctl restart $TOMCAT
sudo systemctl status $TOMCAT | grep Active
sleep 2

# Deploy WAR file (replace "your_war_file.war" with the actual path to your WAR file)
echo "${YELLOW}Deploy WAR file...${RESET}"
sudo cp your_war_file.war /opt/$TOMCAT/webapps/
sleep 2

# Restart Tomcat to apply changes
sudo systemctl restart $TOMCAT
sudo systemctl status $TOMCAT | grep Active
sleep 2

# Test $tomcat installation
echo "${YELLOW}Testing Tomcat installation...${RESET}"
sleep 5
sudo apt-get install curl
curl http://localhost:$CONNECTOR_PORT | grep 'successfully installed Tomcat'

echo "${GREEN}${BOLD}$tomcat installation, configuration, and WAR deployment completed.${RESET}"

# Update Alisa for Log management
#clear;
echo "${YELLOW}Update Alisa for $TOMCAT Log management...${RESET}"
add_alias() {
	echo "alias $TOMCAT='/opt/$TOMCAT/logs/catalina.out'" >> ~/.bashrc
	source ~/.bashrc
	echo "${GREEN}${BOLD}Alias $TOMCAT has been added and the .bashrc file has been sourced...${RESET}"
}

# Prompt user for input
read -p "Do you want to add the alias? (yes/no): " response

# Check user's response
if [ "$response" = "yes" ]; then
    add_alias
    echo "Alias added successfully."
elif [ "$response" = "no" ]; then
    echo "No alias added. Exiting script."
else
    echo "Invalid response. Please enter 'yes' or 'no'."
fi

