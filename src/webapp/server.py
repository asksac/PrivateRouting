#!/usr/bin/env python3
"""
A simple HTTP Server in python for logging requests
Usage:
  ./server.py [<port>]
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
from sys import argv
import time
import json 

serverHost = ""
serverPort = 8080

class MyServer(BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(200)
    self.send_header("Content-type", "text/html")
    self.end_headers()
    response = '''<html>
  <head>
    <title>AWSome WebServer</title>
  </head>
  <body>
    <p>Request Path: <pre>{}</pre></p>
    <p>Client IP: <pre>{}</pre></p>
    <p>Headers: <pre>{}</pre></p>
  </body>
</html>
'''
    self.wfile.write(bytes(response.format(self.path, json.dumps(self.client_address), self.headers.as_string()), "utf-8"))

if __name__ == "__main__": 
  if len(argv) > 1:
    serverPort = int(argv[1])

  webServer = HTTPServer((serverHost, serverPort), MyServer)
  print("Server started http://%s:%s" % (serverHost, serverPort))

  try:
    webServer.serve_forever()
  except KeyboardInterrupt:
    pass

  webServer.server_close()
  print("Server stopped.")