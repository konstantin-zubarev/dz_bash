#!/bin/bash
# Install


mkdir /var/log/bash_access
chown vagrant /var/log/bash_access
yum install vim mailx -y
cp /vagrant/scripts/main.sh /etc/init.d/
chmod +x /etc/init.d/main.sh
cp /vagrant/access.log /var/log/bash_access/
echo "*/1 * * * * root /etc/init.d/main.sh" >>/etc/crontab
systemctl restart crond.service
