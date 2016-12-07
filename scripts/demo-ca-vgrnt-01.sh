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
/bin/cp /vagrant/files/demo-ca-vgrnt-01/puppet.conf /etc/puppet/.
# puppet server conf
/bin/cp /vagrant/files/demo-ca-vgrnt-01/logback.xml /etc/puppetserver/.
/bin/cp /vagrant/files/demo-ca-vgrnt-01/bootstrap.cfg /etc/puppetserver/.
/bin/cp /vagrant/files/demo-ca-vgrnt-01/webserver.conf /etc/puppetserver/conf.d/.
/bin/cp /vagrant/files/demo-ca-vgrnt-01/puppetserver /etc/sysconfig/.
ln -s /var/lib/puppet/ssl /etc/puppet/ssl

echo "Starting the puppetmaster, this will generate a cert."
service puppetserver start

echo "Adding custom cert-copying user."
# pw is "puppet-cert". Creative AND secure!
useradd -g puppet -p '$1$usjK3dEi$73/.frA1u6D65y9WrqEQX0' puppet-cert
mkdir /home/puppet-cert/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4reA361LptwXRmGcRkrLDw1MNRoRvUfBh06+oEqaoOfIAVzc3PkMhrDFcfOzHLjTcAxytVTAbF/0vGSBrd76N5ay4B37SoUErO8nsbh+DxCfwhBJ4vCQq76Uxe7sIwwcNb9RuEyxe9Wo576/eOaG3M6s/qlo62i9qbmk7zH/6fnjOZ6ZH1pj4aATU69Zy+GdkYBhrFf15SvUXJc3qLrT4xCaIuAJ1ZFk3B3F0uDCZ7N0FfMQEpuRbU6p+ZcERhPAOHEP8Px4PpADay+uL/3apLn9sWCfTa5iZWYultmDNKJmmdxLLTBzEaUvS3hgF0bPpbZEIRZSYt1CgxORU7rByQ== puppet-cert@demo-ca-vgrnt-01.local" > /home/puppet-cert/.ssh/authorized_keys
chmod 600 /home/puppet-cert/.ssh/id_rsa.pub
chown puppet-cert:puppet /home/puppet-cert/.ssh/id_rsa.pub

echo "Generating CM cert."
puppet cert generate demo-cm-vgrnt.local
# /bin/cp /var/lib/puppet/ssl/ca/signed/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/.
# /bin/cp /var/lib/puppet/ssl/private_keys/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/private_demo-cm-vgrnt.local.pem #name change!
# /bin/cp /var/lib/puppet/ssl/public_keys/demo-cm-vgrnt.local.pem /vagrant/tmp/demo_certs/public_demo-cm-vgrnt.local.pem #name change!

echo "Starting services and ensuring they start on boot."
service puppet start
chkconfig puppetserver on
chkconfig puppet on

echo "Done."
