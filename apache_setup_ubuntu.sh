#!/bin/bash
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset to default color

clear;
echo "${RED}Welcome to Apache install script${RESET}";
sleep 2;

# Update package list
echo "${YELLOW}Update the system first${RESET}";
sleep 2;
#sudo apt update
echo "${YELLOW}download apache2${RESET}";
sudo apt install apache2 -y

# Start & Enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2 | grep Active
echo "${GREEN}Apache Setup done...${RESET}"
sleep 2;

# Navigate to Apache configuration directory
cd /etc/apache2/sites-available
# Create a virtual host configuration file
read -p ">> Enter the name of (${BOLD}Virtual Host${RESET}) : " CREATE_HOST
echo "${RED}${BOLD}You entered: $CREATE_HOST${RESET}"
read -p ">> Enter the Domain name for Virtual Host (${BOLD}DOMAIN NAME${RESET}) : " CREATE_DOMAIN
echo "${RED}${BOLD}You entered: $CREATE_DOMAIN${RESET}"
echo "<VirtualHost *:80>
ServerName $CREATE_DOMAIN
ServerAlias www.$CREATE_DOMAIN
DocumentRoot \"/var/www/html/$CREATE_HOST\"
ErrorLog \"/var/log/apache2/$CREATE_HOST-error_log\"
CustomLog \"/var/log/apache2/$CREATE_HOST-access_log\" combined
</VirtualHost>" > $CREATE_HOST.conf
echo "${YELLOW}$CREATE_HOST.conf successfully created.${RESET}"
sleep 2;

# Site Enable and Reload
echo "${YELLOW}Site $CREATE_HOST Enable and Reload.${RESET}"
a2ensite $CREATE_HOST.conf
systemctl reload apache2
sleep 2;

# Navigate to the web root directory
cd /var/www/html/
rm -rf index.html
mkdir $CREATE_HOST
cd $CREATE_HOST

# Create an HTML file for the virtual host
echo "${YELLOW}Create an HTML file for the virtual host..${RESET}"
echo "<html>
<body>
<h1><p style=\"color:DodgerBlue;\"><a href=\"http://testing.server.tv/\">!!Welcome to $CREATE_DOMAIN!!</a></p></h1>
</body>
</html>" > index.html
echo "${YELLOW}Index.html successfully created.${RESET}"
sleep 2;

# Navigate back to the parent directory
cd ..
chown -R www-data:www-data $CREATE_HOST

# Firewall installation, start, and status check
echo "${YELLOW}Check firewall for Apache.${RESET}"
sleep 2;
# Check UFW status
ufw_status=$(sudo ufw status)

# Check if UFW is disabled
if echo "$ufw_status" | grep -q "inactive"; then
    echo "UFW is currently disabled. Enabling UFW..."
    sudo ufw enable
else
    echo "UFW is already enabled."
fi

# Allow port 80
echo "${YELLOW}Allow port 80 for Apache...${RESET}"
sudo ufw allow 80

# Display updated UFW details
ufw_status_after=$(sudo ufw status)

echo "Updated UFW Status:"
echo "$ufw_status_after"

echo "${GREEN}${BOLD}Apache installation completed successfully.${RESET}"


# Test $tomcat installation
echo "${YELLOW}Testing Tomcat installation...${RESET}"
sleep 5
sudo apt-get install curl
curl http://localhost/$CREATE_HOST | grep '$CREATE_HOST'