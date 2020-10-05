#!/usr/bin/env python3
"""
A simple HTTP Server in python for logging requests
Usage:
  ./server.py [<port>]
"""

import os, signal, sys
import logging, logging.handlers
from http.server import BaseHTTPRequestHandler, HTTPServer
from sys import argv
import time
import json 

def exit_handler(sig, frame): 
  logging.info('Exit handler invoked, preparing to exit gracefully.')
  logging.shutdown()
  print('Goodbye!')
  sys.exit(0)

class MyServer(BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(200)
    self.send_header('Content-type', 'text/html')
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
    self.wfile.write(bytes(response.format(self.path, json.dumps(self.client_address), self.headers.as_string()), 'utf-8'))

  def log_message(self, format, *args): 
    # by default logs are written to stderr, so we override log_message to write to logger
    logging.info('%s - - [%s] %s\n' % (self.client_address[0], self.log_date_time_string(), format%args))

# define default parameter values
defaults = dict(
  LOG_FILENAME        = '/var/log/PrivateRouting/websvr.log', 
  LOG_LEVEL           = 'INFO', 
  MAX_LOG_FILESIZE    = 10*1024*1024, # 10 Mbs
)

if __name__ == '__main__': 
  serverHost = ''
  serverPort = 8080

  logFileHandler = logging.handlers.RotatingFileHandler(defaults['LOG_FILENAME'], mode = 'a', maxBytes = defaults['MAX_LOG_FILESIZE'], backupCount = 5)
  stdoutHandler = logging.StreamHandler(sys.stdout)
  logging.basicConfig(handlers = [stdoutHandler, logFileHandler], format = '%(asctime)s - %(levelname)s - %(message)s', level = defaults['LOG_LEVEL'])

  signal.signal(signal.SIGINT, exit_handler)
  signal.signal(signal.SIGTERM, exit_handler)
  print('Press Ctrl+C to exit')

  if len(argv) > 1:
    serverPort = int(argv[1])

  while True: 
    webServer = HTTPServer((serverHost, serverPort), MyServer)
    logging.info('Server started http://%s:%s' % (serverHost, serverPort))

    try:
      webServer.serve_forever()
    except Exception as e:
      logging.error('Exception in serve_forever()', exc_info=e)
      try:
        webServer.socket.close()
      except:
        pass

  webServer.server_close()
  logging.info('WebServer stopped.')