#! /bin/bash

echo "Please make sure you're running this AFTER setting up the CA and BEFORE the Compile Master."

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
rpm -i https://download.postgresql.org/pub/repos/yum/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-3.noarch.rpm
yum makecache

echo "Moving installation over and symlinking."
mkdir -p /demo-local/var/lib/pgsql
ln -s /demo-local/var/lib/pgsql /var/lib/pgsql
ln -s /demo-local/var/lib/puppet /var/lib/puppet
mkdir -p /demo-local/var/lib/puppetdb
ln -s /demo-local/var/lib/puppetdb /var/lib/puppetdb

echo "Installing packages."
yum -y install puppet-3.8.7 postgresql94-server postgresql94-contrib puppetdb-2.3.8

if [ $? != 0 ]; then
  echo "Installation failed, ending script run now."
  exit;
fi

echo "Initializing database."
service postgresql-9.4 initdb

echo "Copying over pre-configured conf files."
# psql conf
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/postgresql.conf /demo-local/var/lib/pgsql/9.4/data/.
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/pg_hba.conf /demo-local/var/lib/pgsql/9.4/data/.
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/puppet.conf /etc/puppet/.
# puppetdb conf
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/config.ini /etc/puppetdb/conf.d/.
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/jetty.ini /etc/puppetdb/conf.d/.
/bin/cp /vagrant/files/demo-pdb-vgrnt-01/database.ini /etc/puppetdb/conf.d/.

echo "Fixing perms for puppetdb. This is due to bug in the puppetdb-2.3 rpm."
chown -R puppetdb:puppetdb /demo-local/var/lib/puppetdb

echo "Running puppet to obtain SSL certs for puppetdb. Ignore the 'nil:NilClass' error."
puppet agent -t --server=demo-ca-vgrnt-01.local

echo "Setting up certs for puppetdb."
puppetdb ssl-setup

echo "Starting PGSQL server."
service postgresql-9.4 start
# let's not rush things, it causes errors for the scripts immediately after this.
sleep 10

echo "Creating DB account & database for PuppetDB."
psql -U postgres -c "CREATE USER puppetdb WITH PASSWORD 'puppetdb';"
createdb -U postgres -O puppetdb puppetdb
psql -U postgres -d puppetdb -c 'create extension pg_trgm'

echo "If you want to test access, run this command:
psql -U puppetdb -d puppetdb
"

echo "Starting other services and ensuring they start on boot."
service puppet start
service puppetdb start
chkconfig puppetdb on
chkconfig postgresql-9.4 on
chkconfig puppet on

echo "Done."
