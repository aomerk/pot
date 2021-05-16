#!/bin/sh


#install required packages
sudo apt-get update -y
sudo apt install git zsh -y 
sudo apt-get install  wget curl git python3-virtualenv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind -y

# install docker
sudo apt-get install \
	    apt-transport-https \
		    ca-certificates \
			    curl \
				    gnupg \
					    lsb-release -y

 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

 echo \
	   "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y


sudo apt install supervisor -y
sudo apt-get install authbind
sudo apt install nginx


