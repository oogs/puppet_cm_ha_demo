#! /bin/sh

echo "Please make sure you're running this FIRST"

echo "Ensuring this is a Vagrant environment ..."
if grep -q vagrant /etc/shadow; then
    echo " ... This IS a vagrant environment! Continuing."
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
yum -y install puppet-3.8.7 puppetserver-1.1.2

if [ $? != 0 ]; then
  echo "Installation failed, ending script run now."
  exit;
fi

echo "Copying over pre-configured conf files."
# puppet conf
cp /vagrant/files/demo-ca-vgrnt-01/puppet.conf /etc/puppet/.
# puppet server conf
cp /vagrant/files/demo-ca-vgrnt-01/logback.xml /etc/puppetserver/.
cp /vagrant/files/demo-ca-vgrnt-01/bootstrap.cfg /etc/puppetserver/.
cp /vagrant/files/demo-ca-vgrnt-01/webserver.conf /etc/puppetserver/conf.d/.
cp /vagrant/files/demo-ca-vgrnt-01/puppetserver /etc/sysconfig/.
ln -s /var/lib/puppet/ssl /etc/puppet/ssl

echo "Starting the puppetmaster, this will generate a cert."
service puppetserver start

echo "Generating CM cert and stashing it on /vagrant."
puppet cert generate demo-cm-vgrnt.local
cp /var/lib/puppet/ssl/ca/signed/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/.
cp /var/lib/puppet/ssl/private_keys/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/private_demo-cm-vgrnt.local.pem #name change!
cp /var/lib/puppet/ssl/public_keys/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/public_demo-cm-vgrnt.local.pem #name change!

echo "Starting services and ensuring they start on boot."
service puppet start
chkconfig puppetserver on
chkconfig puppet on

echo "Done."
