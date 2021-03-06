# NOTE
Make sure you put the local charm in the required folder structure
It must be in some_directory/charm/(ubuntu_distro)/storm.  Make sure this project is cloned into a directory called storm (I'm sorry, it's a hack, but I didn't want to call the repository "storm")

my command was `juju deploy -v --repository=/home/my_user/charm/ local:storm stormmaster`

# Overview

This charm provides access to Storm, the distributed realtime computation system. The Charm allows you
to setup a master and one or more workers. The supervisor contains Nimbus and the UI.
The workers containi a supervisor, a DRPC server and one or more workers when a topology is deployed.
A relation with zookeeper is required.

# Usage

To setup a test environment::

    juju bootstrap
    juju deploy zookeeper
    juju deploy storm stormmaster
    juju deploy storm stormworker
    juju add-relation stormmaster zookeeper
    juju add-relation stormworker zookeeper
    juju add-relation stormmaster:master stormworker:worker
    juju expose stormmaster
    juju expose stormworker

The UI is running on port 8080 of the stormmaster.

Optionally you can use a configuration file, e.g. config.saml.

An example could be:
stormworker:
  nimbusmemory: 512
  uimemory: 384
  supervisormemory: 128
  workermemory: 128
  nimbusport: 6627
  uiport: 8080
  zookeeperport: 2181
  drpcport: 3772
  numberofworkers: 5
  startingworkerport: 6700

The memory requirements of several components can be specified in 
megabytes: nimbus, ui, supervisor and worker.

Also the default ports can be changed for nimbus, ui, zookeeper and drpc.
These processes run as a non-priviledged user hence the port needs to be
higher than 1024.

Finally each worker node can have multiple workers running on it.
The startingworkerport defines the port of the first worker, e.g. 6700.
The numberofworkers defines how many workers are started up on each worker
node. The ports will be a combination of these two configuration options. 
If the starting port is 6700 and the number of workers is 3, then the ports
that are used will be: 6700 6701 6702.

You can use add-unit to add additional workers. However for the moment the
master can not be scaled to more than one. In order for the master to be scaled,
a distributed file system would have to synchronize /mnt/storm between different
peers and if the master died, a zookeeper master selection process would have to
select a new master and all workers would have to change their nimbus server
reference to point to the new master and restart.
