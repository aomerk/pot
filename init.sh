
#install required packages
sudo apt-get update
sudo apt install git zsh 
sudo apt-get install git python3-virtualenv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind

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




# install zsh and ohmyzsh
# sudo chsh -s $(which zsh)
# sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


#
# Install cowrie
#
sudo adduser --disabled-password cowrie
sudo su - cowrie

git clone http://github.com/cowrie/cowrie

cd /home/cowrie/cowrie
virtualenv --python=python3 cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install --upgrade -r requirements.txt

cp /home/cowrie/cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie/etc/cowrie.cfg
sed -i -e "s/hostname = .*/hostname = UbuntuServer/g" /home/cowrie/cowrie/etc/cowrie.cfg
sed -i -e "s/listen_endpoints = tcp:2222:interface=0.0.0.0/listen_endpoints = tcp:22:interface=0.0.0.0/g" /home/cowrie/cowrie/etc/cowrie.cfg

# make a non root user listen ssh port
exit
sudo apt-get install authbind
sudo touch /etc/authbind/byport/22
sudo chown cowrie:cowrie /etc/authbind/byport/22
sudo chmod 770 /etc/authbind/byport/22


sed -i -e "s/#Port 22/Port 23/g" /etc/ssh/sshd_config
sudo service ssh restart

sudo apt install supervisor

echo "
[program:cowrie]
command=/home/cowrie/cowrie/bin/cowrie start
directory=/home/cowrie/cowrie/
user=cowrie
autorestart=true
redirect_stderr=true
" > /etc/supervisor/conf.d/cowrie.conf


sudo supervisorctl update

wget -O splunk-8.2.0-e053ef3c985f-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.2.0&product=splunk&filename=splunk-8.2.0-e053ef3c985f-linux-2.6-amd64.deb&wget=true'

sudo dpkg -i splunk-8.2.0-e053ef3c985f-linux-2.6-amd64.deb

sudo /opt/splunk/bin/splunk enable boot-start

sudo service splunk start

echo "Register a HTTP Event source from splunk dashboard and get token. Then, in etc/cowrie.cfg enable splunk output and insert token"


