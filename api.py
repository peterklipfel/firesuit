from flask import Flask, request
from flask.ext.restful import reqparse, abort, Api, Resource

import json

app = Flask(__name__)
api = Api(app)

parser = reqparse.RequestParser()

@app.route('/', methods=['POST'])
def eatJson():
  try:
    if request.method == "POST":
      print request.form
      for blob in request.form:
        print blob
        print json.loads(blob)
      return json.dumps({'ok' : True})
    else:
      return json.dumps({'ok' : False})
  except Exception, e:
    return json.dumps({'ok' : False})

# @crossdomain(origin='*')

if __name__ == '__main__':
  app.run(debug=True)