#!/bin/bash

# Install Dependencies
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
# Install Ansible and tree
sudo apt-get install ansible -y
ansible --version
sudo apt-get install tree -y
# Install AWS dependencies
sudo apt install python3-pip
sudo pip3 install awscli
sudo pip3 install boto boto3
sudo apt-get update -y
sudo apt-get upgrade -y