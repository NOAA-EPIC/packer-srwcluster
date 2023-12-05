#!/bin/bash
echo 'Installing lmod'
apt install lmod -y

echo 'Configuring modules.sh'
cat >/etc/profile.d/modules.sh <<EOL
shell=fetch_and_run

if [ -f /usr/share/lmod/lmod/init/$shell ]; then
   . /usr/share/lmod/lmod/init/$shell
else
   . /usr/share/lmod/lmod/init/sh
fi
EOL

echo 'Updating UFS weather app and regional workflow'
export HOME=/home/ubuntu
git config --global --add safe.directory /home/ubuntu/ufs-srweather-app
git config --global --add safe.directory /home/ubuntu/ufs-srweather-app/regional_workflow
echo $(ls)
cd ~/ufs-srweather-app
git remote add epic https://github.com/NOAA-EPIC/ufs-srweather-app
git remote update
git checkout epic/feature/ami
git checkout -b feature/ami
cd regional_workflow
git remote add epic https://github.com/NOAA-EPIC/regional_workflow
git remote update
git checkout epic/feature/ami
git checkout -b feature/rw/ami
chown -R ubuntu /home/ubuntu/ufs-srweather-app

echo 'Deleting crontab entries'
crontab -u ubuntu -r

echo 'Installing Bastion Key'
aws ssm get-parameter --region us-east-1 --name bastion_public_key | jq -r .Parameter.Value >> ~/.ssh/authorized_keys
