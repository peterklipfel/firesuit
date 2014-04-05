from flask import Flask, request
from flask.ext.restful import reqparse, abort, Api, Resource

import json
import pika
import sys
import logging
import yaml
import os

logging.basicConfig()

app = Flask(__name__)
api = Api(app)

filePath = os.path.dirname(os.path.realpath(__file__))+'/.firesuit/config.yml'
f = open(filePath)
config = yaml.safe_load(f)
f.close()

parser = reqparse.RequestParser()

HOST = config['rabbitip']

def is_json(myjson):
  try:
    json_object = json.loads(myjson)
  except ValueError, e:
    return False
  return True

@app.route('/', methods=['POST'])
# @crossdomain(origin='*')
def eatJson():
  try:
    if request.method == "POST":
      for blob in request.form:
        if is_json(blob):
          connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=(HOST), port=5672))
          channel = connection.channel()
          channel.exchange_declare(exchange='direct_logs',
                                   type='direct')

          channel.basic_publish(exchange='stormExchange',
                                routing_key="exclaimTopology",
                                body=blob)
          connection.close()
        else:
          return json.dumps({'ok' : False})
    
      return json.dumps({'ok' : True})
    else:
      return json.dumps({'ok' : False})
  except Exception, e:
    print e
    return json.dumps({'ok' : False})


@app.route('/', methods=['GET'])
def statuscheck():
  json_results = {'ok' : True}
  return json.dumps(json_results)

if __name__ == '__main__':
  app.run(debug=True)
