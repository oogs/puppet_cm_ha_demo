#! /bin/sh

echo "Please make sure you're running this AFTER setting up the CA and PuppetDB."

echo "Ensuring this is a Vagrant environment ..."
if grep -q vagrant /etc/shadow; then
    echo " ... This IS a vagrant environement! Continuing."
else
    echo " ... This is NOT a vagrant environment. Exiting."
    exit 1
fi

echo "Vagrant-only folder creation."
mkdir /demo-local

echo "Installing repos for Vagrant environment."
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -i https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum makecache

echo "Moving puppet installation over and symlinking."
mkdir -p /demo-local/var/lib/puppet
ln -s /demo-local/var/lib/puppet /var/lib/puppet
mkdir -p /demo-local/usr/share/puppetserver
ln -s /demo-local/usr/share/puppetserver /usr/share/puppetserver

echo "Installing packages."
# yum -y install java-1.7.0-openjdk-1.7.0.75
yum -y install puppet-3.8.7 puppetserver-1.1.2 puppetdb-terminus

if [ $? != 0 ]; then
  echo "Installation failed, ending script run now."
  exit;
fi

echo "Copying over pre-configured conf files."
# puppet conf
/bin/cp /vagrant/files/demo-cm-vgrnt-01/puppet.conf /etc/puppet/.
/bin/cp /vagrant/files/demo-cm-vgrnt-01/puppetdb.conf /etc/puppet/.
/bin/cp /vagrant/files/demo-cm-vgrnt-01/routes.yaml /etc/puppet/.
# puppet server conf
/bin/cp /vagrant/files/demo-cm-vgrnt-01/logback.xml /etc/puppetserver/.
/bin/cp /vagrant/files/demo-cm-vgrnt-01/bootstrap.cfg /etc/puppetserver/.
/bin/cp /vagrant/files/demo-cm-vgrnt-01/webserver.conf /etc/puppetserver/conf.d/.
/bin/cp /vagrant/files/demo-cm-vgrnt-01/puppetserver /etc/sysconfig/.
# Just to make sure we get clean empty runs from the get-go.
mkdir -p /vagrant/tmp/environments/production

echo "Generating correctly signed cert with bad/empty puppet run. Ignore these errors."
puppet agent -t --server=demo-ca-vgrnt-01.local --noop

echo "Adding custom cert-copying cert."
mkdir ~/.ssh
chmod 700 ~/.ssh
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA4reA361LptwXRmGcRkrLDw1MNRoRvUfBh06+oEqaoOfIAVzc
3PkMhrDFcfOzHLjTcAxytVTAbF/0vGSBrd76N5ay4B37SoUErO8nsbh+DxCfwhBJ
4vCQq76Uxe7sIwwcNb9RuEyxe9Wo576/eOaG3M6s/qlo62i9qbmk7zH/6fnjOZ6Z
H1pj4aATU69Zy+GdkYBhrFf15SvUXJc3qLrT4xCaIuAJ1ZFk3B3F0uDCZ7N0FfMQ
EpuRbU6p+ZcERhPAOHEP8Px4PpADay+uL/3apLn9sWCfTa5iZWYultmDNKJmmdxL
LTBzEaUvS3hgF0bPpbZEIRZSYt1CgxORU7rByQIBIwKCAQEAu9nfz0Zx4gbRdNSI
zIcdRvxjtvhX11i2S4pjbt66opQpYDcAJM5a1gAukZ4Jb5HTwz2DnY9dm5/2qrmt
Ruvz5OqUNgo2nNSdeVhxWL1vw1bqxV30E86jwYCnJ6i1BxipqOBZp1V9HXaEosKe
pgDWJKs+4aJPnntbUh16CATbW3W36wFAgzCBxt/BI//7l/iyPd3ucwiv8sX7hKSv
0OLQkhlkzVza0+jgnHVyKQzMI55vRcuBCwFu9yAaa1duEJjHIgsiWPE/jtxDzf2I
719A+5MpJdyGlzAM3f4BjfC8WBB0CmxXRKTSmCigTe1RMoJ2sG1iEExCmVS7hUg5
9DwGCwKBgQD2R+1j7nkYpPY9FuDcc+D+MFFm1ayVk+D3R8G7r1tPQAYKyVxr0m5s
684rsS6RiCvD3bKcSoL1+y5kbeg0sMSH1BtF5P8b76TVy1coDtyxoIzuCSLHFuVM
zr/iw1X32JEmm11EDZ9uxsaDBFJHEjmk8F+w1CGnyjnIvr7LuNr8eQKBgQDrqe19
Zmj1OvzkTybJSFAO4Y0QBTb15ateE6TLF8CI6eMVsRxg8bp2GP+ma706f5OCM3b7
WbXGEuffCiH7TFA2Z2LVjv2CW+FXYJ20uZyLI//d/vXmVC39O0eZZf/l10zXQV1g
Aa+cMiBmZK9nkyBDL9tjkY/M+hETCP2aJKj70QKBgQCo4N1L1rlv/BaQSjPKXhaf
rBqPqHZX8F+/galqwWMvB1SZrqXGRycmHgm3j3BjyxayMZ8MFdYlBAKOAjjTrGmB
tgQSq6eeIKuLSZrZo8qIbhd+py3KWNe/o7bHYV+FYU2W0O9/H0jA/VTsIDhrP7J/
usVGDc3vZhj+rq63lLNrSwKBgDyZaPRcKZ4lHHU47LdqXbqvBwQemRqoxap6FG68
9v6iitmxMy7fErCnV65zec02v4fhWRwPwQcMLP7WuEfvDU/RcS+ZzCjVzDsKNy54
3xx2+KbMiF/MgNq3eM+sg6GAgXkuELJJk46Qi/0Sk4EIk0R6BTbcSYx60TDHzC7z
e+j7AoGASMmYXSf8FaHtSe9NLsXURn0v0U2UsojD+brG3E9hHZAovOFHFEHxExBj
qxT9X32uUvHrnDAnNeOqVVxuEFXC+PL46dbk3ICm/TO6CeWJqtITDhKFEKNbKkmR
VyyVVgZgmqXQOsA0at5NePDlqvvhTJkoCqboVU+n2YM6pPmNWTc=
-----END RSA PRIVATE KEY-----" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4reA361LptwXRmGcRkrLDw1MNRoRvUfBh06+oEqaoOfIAVzc3PkMhrDFcfOzHLjTcAxytVTAbF/0vGSBrd76N5ay4B37SoUErO8nsbh+DxCfwhBJ4vCQq76Uxe7sIwwcNb9RuEyxe9Wo576/eOaG3M6s/qlo62i9qbmk7zH/6fnjOZ6ZH1pj4aATU69Zy+GdkYBhrFf15SvUXJc3qLrT4xCaIuAJ1ZFk3B3F0uDCZ7N0FfMQEpuRbU6p+ZcERhPAOHEP8Px4PpADay+uL/3apLn9sWCfTa5iZWYultmDNKJmmdxLLTBzEaUvS3hgF0bPpbZEIRZSYt1CgxORU7rByQ== puppet-cert@demo-ca-vgrnt-01.local" > /home/puppet-cert/.ssh/id_rsa.pub
chmod 644 ~/.ssh/id_rsa.pub

echo "Copying demo-cm-vgrnt.local cert over from CA."
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa puppet-cert@demo-ca-vgrnt-01.local:/var/lib/puppet/ssl/certs/demo-cm-vgrnt.local.pem /var/lib/puppet/ssl/certs/demo-cm-vgrnt.local.pem
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa puppet-cert@demo-ca-vgrnt-01.local:/var/lib/puppet/ssl/private_keys/demo-cm-vgrnt.local.pem /var/lib/puppet/ssl/private_keys/demo-cm-vgrnt.local.pem
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa puppet-cert@demo-ca-vgrnt-01.local:/var/lib/puppet/ssl/public_keys/demo-cm-vgrnt.local.pem /var/lib/puppet/ssl/public_keys/demo-cm-vgrnt.local.pem
chown -R puppet:puppet /var/lib/puppet/ssl

echo "Moving an errant cert around..."
mkdir /var/lib/puppet/ssl/ca
chown puppet:puppet /var/lib/puppet/ssl/ca
ln -s /var/lib/puppet/ssl/crl.pem /var/lib/puppet/ssl/ca/ca_crl.pem

echo "Starting services and ensuring they start on boot."
service puppetserver start
service puppet start
chkconfig puppetserver on
chkconfig puppet on

echo "Done."
