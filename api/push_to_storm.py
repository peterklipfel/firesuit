#!/usr/bin/env python
import pika
import sys

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='ec2-54-81-253-74.compute-1.amazonaws.com'))
channel = connection.channel()

channel.exchange_declare(exchange='direct_logs',
                         type='direct')

severity = sys.argv[1] if len(sys.argv) > 1 else 'info'
message = ' '.join(sys.argv[2:]) or 'Hello World'
channel.basic_publish(exchange='stormExchange',
                      routing_key="exclaimTopology",
                      body=message)
print " [x] Sent %r:%r" % (severity, message)
connection.close()
