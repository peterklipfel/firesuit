# Overview
This is a charm for deploying [flask](http://flask.pocoo.org/).  Currently, my goal with this is to allow flask to act as a json parsing interface in front of rabbitmq, so it will need to relate with rabbitmq well.  Also, this charm is being written to be deployed on AWS

# Usage

Step by step instructions on using the charm:

    juju deploy flask

When it is deployed, you should e able to post requests to the url provided by aws 

## Scale out Usage

TODO

## Known Limitations and Issues

Currently, this charm is only written to support aws.  I have no testing or usage in other cases.

# Configuration

TODO

# Contact Information

This charm is maintained by Peter Klipfel

please post issues at github.com/peterklipfel/flask_charm

## Upstream Project Name

TODO

## Charm Contact

This charm is maintained by Peter Klipfel

please post issues at github.com/peterklipfel/flask_charm

