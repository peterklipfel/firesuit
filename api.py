from flask import Flask, request
from flask.ext.restful import reqparse, abort, Api, Resource

import json
import pika
import sys

app = Flask(__name__)
api = Api(app)

parser = reqparse.RequestParser()

@app.route('/', methods=['POST'])
# @crossdomain(origin='*')
def eatJson():
  try:
    if request.method == "POST":
      for blob in request.form:
        connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
        channel = connection.channel()
        channel.exchange_declare(exchange='direct_logs',
                                 type='direct')

        message = ' '.join(sys.argv[2:]) or '{"Hello": "World"}'
        channel.basic_publish(exchange='stormExchange',
                              routing_key="exclaimTopology",
                              body=message)
        print " [x] Sent %r:%r" % (severity, message)
        connection.close()

      return json.dumps({'ok' : True})
    else:
      return json.dumps({'ok' : False})
  except Exception, e:
    return json.dumps({'ok' : False})


if __name__ == '__main__':
  app.run(debug=True)