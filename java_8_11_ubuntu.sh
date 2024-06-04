#!/bin/bash
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset to default color

# Java Installation Script for Ubuntu
echo "${YELLOW}Java Installation Script for Ubuntu..${RESET}"
echo "Choose Java version to install:"
echo "1. Java 8"
echo "2. Java 11"
read -p "Enter your choice (1 or 2): " JAVA_VERSION

case $JAVA_VERSION in
  1)
    # Install Java 8 (OpenJDK)
    sudo apt update
    sudo apt install -y openjdk-8-jdk
    JAVA_HOME_PATH="/usr/lib/jvm/java-8-openjdk-amd64"
    ;;
  2)
    # Install Java 11 (OpenJDK)
    sudo apt update
    sudo apt install -y openjdk-11-jdk
    JAVA_HOME_PATH="/usr/lib/jvm/java-11-openjdk-amd64"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Verify Java installation
echo "${YELLOW}Verify Java installation version for Ubuntu..${RESET}"
java -version

# Set Java environment variables (optional)
echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

# Reload Bash configuration
source ~/.bashrc

echo "${GREEN}${BOLD}Java installation and setup completed successfully.${RESET}"
