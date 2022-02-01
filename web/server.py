#!/bin/env python3
""" Simple python web app """

import socket
from bottle import route, run, HTTPResponse

@route('/ping')
def ping():
    """ returns http response 200 """
    return HTTPResponse(status=200)

@route('/hello')
def hello():
    """ returns hello message with hostname """
    return "Hello World! from " +socket.gethostname()
run(host='0.0.0.0', port=5000, debug=True)
