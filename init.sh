
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

sudo apt install nginx

echo "Install Nginx add on for splunk from Browse More apps "

# support splunk like log format
sudo sed -i -e 's/access_log .*;/        # creating a new format called adv\n        log_format adv \x27site="\$server_name" server="\$host” dest_port="\$server_port" \x27\n                       \x27dest_ip="\$server_addr" src="\$remote_addr" src_ip="\$realip_remote_addr" \x27\n                       \x27user="\$remote_user" time_local="\$time_local" protocol="\$server_protocol" \x27\n                       \x27status="\$status" bytes_out="\$bytes_sent" \x27\n                       \x27bytes_in="\$upstream_bytes_received" http_referer="\$http_referer" \x27\n                       \x27http_user_agent="\$http_user_agent" nginx_version="\$nginx_version" \x27\n                       \x27http_x_forwarded_for="\$http_x_forwarded_for" \x27\n                       \x27http_x_header="\$http_x_header" uri_query="\$query_string" uri_path="\$uri" \x27\n                       \x27http_method="\$request_method" response_time="\$upstream_response_time" \x27\n                       \x27cookie="\$http_cookie" request_time="\$request_time" \x27;\n        access_log \/var\/log\/nginx\/access\.log adv;/' /etc/nginx/nginx.conf

# Create data source 
# Choose nginx access log path
# choose nginx_kv for source type

