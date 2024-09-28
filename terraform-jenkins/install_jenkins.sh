#!/bin/bash
sudo apt-get -y update
echo "Install Java JDK 8"
sudo apt-get remove -y openjdk-11-jre-headless
sudo apt-get install -y fontconfig openjdk-17-jre
echo "Install Maven"
sudo apt-get install -y maven
echo "Install git"
sudo apt-get install -y git
echo "Install Jenkins"
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
echo "Install Docker engine"
sudo apt-get update -y
sudo apt-get install docker.io -y
#sudo usermod -a -G docker jenkins
sudo systemctl start docker
sudo apt-get chkconfig docker on


