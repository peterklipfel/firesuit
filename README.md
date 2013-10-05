firesuit
========


For Amazon
----------

This will spin up a couple instances

_This will be scripted soon_: in order to set up storm, after using the aws script, use `juju ssh` to ssh into the correct worker, and get the topology that you want to run.  In a test case, we used the zip file downloaded from https://github.com/peterklipfel/scala-storm-starter as our topology.  Then, to create the deployable jar, we ran `sbt assembly`.

Then, to deploy the topology, we ran
    
    /opt/storm/storm-0.8.1/bin/storm jar /home/ubuntu/scala-storm-starter-master/target/scala-2.9.2/scala-storm-starter-assembly-0.0.2-SNAPSHOT.jar storm.starter.topology.ExclamationTopology ExclamationTopology

_A framework for standing up big data applications_

This project is my undergraduate senior project.  It aims to provide an opinionated boilerplate and framework for setting up data applications.  I have been working with big data tools for a relatively short amount of time, but have noticed that people are often repeating the same patterns.  Nathan Marz had the right idea with a real-time complex event processing unit, and a batch processing unit that picked up afterward.  However, the ecosystem is rapidly growing and expanding.  It would be nice to have a framework that allowed people to switch out functional layers and retain functionality.  Similar to the way that web frameworks provide an opinionated way for people to organize the tools of their choice (javascript libraries, databases, etc.).

The first step is creating a deployment for the system using Ubuntu Juju.

After this, I would like to ensure that there is a way to keep track of schema between the different components.  If hadoop and storm both save into cassandra, they must speak the same schema.

The ultimate goal is to provide abstractions over these technologies that allow them to be swapped out.  
