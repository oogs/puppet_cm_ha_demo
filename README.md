puppet_cm_ha_demo
========================

## Introduction

This is a demo for HA in Puppet. By HA, we mean "multiple Compile Masters that are load balanced behind a proxy". There are other forms of HA that we can not cover in easily using vagrant (HA @ the hypervisor, storage replication, etc) and are therefor outside the scope of this demo.

This project contains a vagrant environment that consists of VMs:

* Puppet Certificate Authority (CA)
    * Central CA for all Puppet agents
* PuppetDB Postgresql
    * Stores facts, reports, catalogs for all Puppet agents
* Puppet Compile Master
    * Handles Puppet catalog compiles from all Puppet agents
* HAProxy
    * Load balancer for Compile Master, and CA functions
* Puppet agent
    * Agent connected to Puppet infrastructure

## Prerequisites

* At least 8 GB of RAM. The VMs defined here are configured to use 8 GB. You can adjust the configs if you wish, but 8 GB is the recommended minimum for this configuration.
* Sufficient disk space for all VMs. If you like to ride the line of a close to full local disk, you'll probably run into issues with this setup.
* There are two vagrant.yml files, one for Mac and one for Windows.  Symlink the one you need to vagrant.yml.  For example:
    * `ln -s vagrant-mac.yml vagrant.yml`
* The vagrant centos 6 image. You can add it manually using `vagrant box add centos/6`.

## VM Definitions

This project uses Greg Sarjeant's [data-driven-vagrantfile](https://github.com/gsarjeant/data-driven-vagrantfile) to define the virtual machines in yaml format. There is extensive documentation of the Vagrantfile at the data-driven-vagrantfile [project wiki](https://github.com/gsarjeant/data-driven-vagrantfile/wiki). Briefly, the VMs described above are defined in the vagrant.yml file distributed with this project. They should work with no modification to create the VMs and do the appropriate PE installation on each. If you would like to make any modifications to the VMs, change the settings in vagrant.yml. You should not need to make any modifications to the Vagrantfile itself.

## Vagrant Usage

You should be able to create the VMs by doing the following

* Enter `vagrant up` at a command prompt.

This will create the VMs in the proper order. The VMs will be provisioned using scripts in the **scripts** directory.

* **hosts.sh**: creates host file entries for each vm, so that they can resolve each other by name
* **[role].sh**: where [role] is the host type of the system (e.g., demo-ca-vgrnt-01.sh).  These scripts do the heavy lifting.

**NOTE:** If you would like to test the manual instructions or production-ready automation, comment out the requisite provision script from the vagrant.yml file before you bring the systems up.

If you are working on something and want to store files within the git space without worrying about them getting committed to the repository, create a directory called debug-[whatever], and it will be ignored by git.

## Post-install requirements

None!

## Usage

Note: The default box used in this demo, 'centos/6', does not have Guest Additions installed, which is required for port forwading.

HAProxy has a stats page at (http://localhost:9090/stats)
HAProxy has a health check page at (http://localhost:980/service-check)

The demo-agent system is setup to use the HAProxy cnames, and Puppet runs should work.

## Demo steps

1. Start the basic three servers: vagrant up demo-ca-vgrnt-01 demo-pdb-vgrnt-01 demo-cm-vgrnt-01 . These will give you a small puppet environment.
2. When you want to add more servers to the mix, spin up the HA proxy: vagrant up demo-ha-vgrnt-01
3. Reconfigure demo-cm-vgrnt-01's puppet.conf and webserver.conf (comment out the Standalone config settings, uncomment HAP config settings).
4. Restart puppetserver and puppet on demo-cm-vgrnt-01.
5. Test to make sure changes worked on demo-cm-vgrnt-01 (as root): puppet agent -t. Should not give you SSL errors.
6. Spin up more CMs: vagrant up demo-cm-vgrnt-02 demo-cm-vgrnt-03
7. Run puppet on any/all agents. You can watch connections either on the HA Proxy stats page (localhost:9090/stats) or by tailing /var/log/puppetserver/puppetserver-access.log on each CM.

## To-do
