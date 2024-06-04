#!/bin/bash
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset to default color

clear;
echo "${RED}Welcome to nginx page speed install script...${RESET}";
sleep 2;

# Ipdate system
echo "${YELLOW}Update the system first...${RESET}";
sudo apt-get update
sudo apt-get -y upgrade
sleep 2;

# Install Nginx
echo "${YELLOW}Install Nginx...${RESET}"
sudo apt install nginx -y
sleep 2;

# Restart Nginx to apply changes
echo "${YELLOW}Restart Nginx to apply changes...${RESET}"
sudo systemctl restart nginx
sudo systemctl status nginx | grep Active
sleep 2;

# Create a new configuration file in sites-available
echo "${YELLOW}Create a new configuration file in sites-available...${RESET}"
read -p "==>> Enter the name of (Virtual Host) : " CREATE_HOST
echo "${RED}${BOLD}You entered: $CREATE_HOST${RESET}"
read -p "==>> Enter the Domain name for Virtual Host (DOMAIN NAME) : " CREATE_DOMAIN
echo "${RED}${BOLD}You entered: $CREATE_DOMAIN${RESET}"
read -p "==>>Enter the Server Port (80) for $CREATE_DOMAIN : " SERVER_PORT
echo "${RED}${BOLD}You entered: $SERVER_PORT for $CREATE_DOMAIN${RESET}"

sudo tee /etc/nginx/sites-available/$CREATE_HOST > /dev/null <<EOL
server {
    listen $SERVER_PORT;

    server_name $CREATE_DOMAIN;

    location / {
#        proxy_pass http://127.0.0.1:8080/;
#        proxy_set_header Host \$host;
#        proxy_set_header X-Real-IP \$remote_addr;
#        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto \$scheme;
        try_files \$uri \$uri/ =404;
    }

     root /var/www/$CREATE_DOMAIN;
     index index.html;
	
    access_log /var/log/nginx/$CREATE_DOMAIN_access.log;
    error_log /var/log/nginx/$CREATE_DOMAIN_error.log;
}
EOL

# Create the root directory for the new site
sudo mkdir -p /var/www/$CREATE_HOST

# Create a simple index.html file
echo "${YELLOW}Create a simple index.html file for $CREATE_DOMAIN...${RESET}"
echo "<html><body><h1>Welcome to Nginx $CREATE_DOMAIN!</h1></body></html>" | sudo tee /var/www/$CREATE_HOST/index.html > /dev/null

# Create a symbolic link to enable the site
echo "${YELLOW}Create a symbolic link to enable the site $CREATE_DOMAIN...${RESET}"
sudo ln -s /etc/nginx/sites-available/$CREATE_HOST /etc/nginx/sites-enabled/

# Test Nginx configuration
echo "${YELLOW}Test Nginx configuration...${RESET}"
sudo nginx -t
sleep 2;

# Restart Nginx to apply the new site configuration
echo "${YELLOW}Restart Nginx to apply the new site configuration...${RESET}"
sudo systemctl restart nginx
sudo systemctl status nginx | grep Active
sleep 2;

echo "${GREEN}${BOLD}Nginx installation and configuration completed successfully.${RESET}"


# Test Nginx installation
echo "${YELLOW}Testing Nginx ($CREATE_DOMAIN) installation...${RESET}"
sleep 5;
sudo apt-get install curl -y
curl http://localhost:$SERVER_PORT