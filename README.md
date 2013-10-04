firesuit
========


For Amazon
----------
This will spin up a couple instances


_A framework for standing up big data applications_

This project is my undergraduate senior project.  It aims to provide an opinionated boilerplate and framework for setting up data applications.  I have been working with big data tools for a relatively short amount of time, but have noticed that people are often repeating the same patterns.  Nathan Marz had the right idea with a real-time complex event processing unit, and a batch processing unit that picked up afterward.  However, the ecosystem is rapidly growing and expanding.  It would be nice to have a framework that allowed people to switch out functional layers and retain functionality.  Similar to the way that web frameworks provide an opinionated way for people to organize the tools of their choice (javascript libraries, databases, etc.).

The first step is creating a deployment for the system using Ubuntu Juju.

After this, I would like to ensure that there is a way to keep track of schema between the different components.  If hadoop and storm both save into cassandra, they must speak the same schema.

The ultimate goal is to provide abstractions over these technologies that allow them to be swapped out.  
