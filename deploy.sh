# get the server os and version
release="$(lsb_release -d)"

# gotta format this variable weirdly to ensure there is a `tab`
expected="Description:$(echo $'\t')Ubuntu 20.04 LTS"

# check if the script is being run on the right server
# the expected version is Ubuntu 20.04 LTS
if [[ $release == $expected ]];
then
    echo "starting default deployment..."
else
    echo "wrong server version"
    echo "this script supports Ubuntu 20.04 LTS"
    exit 0
fi

# add the microsoft package signing key to list of keys
# also add the package repository
wget "https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

# cleaning up
rm packages-microsoft-prod.deb

# install the dotnet 3.1 sdk
sudo apt install apt-transport-https -y
sudo apt update
sudo apt install dotnet-sdk-3.1 -y

# install nginx
sudo apt install nginx -y

# rewrite the old config file to look like this
sudo echo "server {
    listen 80;
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" > /etc/nginx/sites-available/default

# restart nginx
sudo service nginx restart

# install supervisor
sudo apt install supervisor -y

# figure out the reponame
reponame="${PWD##*/}"

# figure out the project name
for f in *.csproj
    do
    project=${f%%.*}
    done

# create a supervisor config using the above variables
sudo echo "[program:$project]
command=/usr/bin/dotnet  /var/www/$reponame/bin/Debug/netcoreapp3.1/$project.dll
directory=/var/www/$reponame/bin/Debug/netcoreapp3.1
autostart=true
autorestart=true
stderr_logfile=/var/log/$project.err.log
stdout_logfile=/var/log/$project.out.log
environment=ASPNETCORE_ENVIRONMENT=Production
user=www-data
stopsignal=INT" > /etc/supervisor/conf.d/$project.conf

# leave supervisor stopped for now
sudo service supervisor stop

# end the script
exit 0
