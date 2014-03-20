# Apache Cassandra Overview

The Apache Cassandra database is the right choice when you need scalability
and high availability without compromising performance. Linear scalability
and proven fault-tolerance on commodity hardware or cloud infrastructure
make it the perfect platform for mission-critical data. Cassandra's support
for replicating across multiple datacenters is best-in-class, providing lower
latency for your users and the peace of mind of knowing that you can survive
regional outages.

Cassandra's ColumnFamily data model offers the convenience of column indexes
with the performance of log-structured updates, strong support for materialized
views, and powerful built-in caching.

See [cassandra.apache.org](http://cassandra.apache.org) for more information.

# Usage

Cassandra deployments are relatively simple in that they consist of a set of
Cassandra nodes which seed from each other to create a ring of servers::
    
    juju deploy --repository . local:cassandra
    juju add-unit -n 2 cassandra

The service units will deploy and will form a single ring.

The API to Cassandra is supported through Apache Thrift; Thrift is a software
framework for scalable cross-language services development.

See [this documentation](http://wiki.apache.org/cassandra/ThriftInterface) for more details of how
to use this API.

Cassandra recommend using one of the many client options - see
[ClientOptions(http://wiki.apache.org/cassandra/ClientOptions) for more details

To relate the Cassandra charm to a service that understands how to talk to
Cassandra using thrift::

    juju deploy --repository . local:service-that-needs-cassandra
    juju add-relation service-that-needs-cassandra cassandra

# Configuration

Cassandra has a pretty good guess at configuring its Java memory settings to
fit the machine that it has been deployed on.

The charm does support manual configuration of Java memory settings - see the
config.yaml file for more details::

    cassandra:
        auto-memory: false
        heap-size: 8G
        new-gen-size: 250M

However be aware that its recommended that Cassandra always remains in 'real'
memory and should never be swapped out to disk so keep this in mind when
changing these options.

Cassandra sets both is minimum and maximum heap size on startup so will
pre-allocate all memory to avoid freezes during operation (this happens
during normal operation as more memory is allocated to heap.

# Words of Caution

Changing the configuration of a deployed Cassandra cluster is supported; however
it will result in a restart of each Cassandra node as the changes are implemented
which may result in outages.

