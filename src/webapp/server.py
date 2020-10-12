#!/usr/bin/env python3
"""
A simple HTTP Server in python for logging requests
Usage:
  ./server.py [<port>]
"""

import os, signal, sys, time
import logging, logging.handlers
from http.server import BaseHTTPRequestHandler, HTTPServer
import ssl
import json, argparse

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
  LOG_FILENAME        = '/var/log/PrivateRouting/websvr_%s.log', 
  LOG_LEVEL           = 'INFO', 
  MAX_LOG_FILESIZE    = 10*1024*1024, # 10 Mbs
)

if __name__ == '__main__': 
  serverHost = ''
  serverPort = 8080

  parser = argparse.ArgumentParser(description='Run a simple http/https webserver')
  parser.add_argument('port', metavar = 'port', type = int, nargs='?', default = 8080, 
                      help = 'listen port number (default 8080)')
  parser.add_argument('--tls', dest = 'tls', action = 'store_true', default = False,
                      help = 'turns on https mode, only tls connections are accepted (default False)')
  parser.add_argument('--keyfile', dest = 'keyfile', default = 'key.pem',
                      help = 'full path to key.pem file')
  parser.add_argument('--certfile', dest = 'certfile', default = 'cert.pem',
                      help = 'full path to cert.pem file')

  args = parser.parse_args()

  logFileHandler = logging.handlers.RotatingFileHandler(defaults['LOG_FILENAME'] % (serverPort), mode = 'a', maxBytes = defaults['MAX_LOG_FILESIZE'], backupCount = 5)
  stdoutHandler = logging.StreamHandler(sys.stdout)
  logging.basicConfig(handlers = [stdoutHandler, logFileHandler], format = '%(asctime)s - %(levelname)s - %(message)s', level = defaults['LOG_LEVEL'])

  signal.signal(signal.SIGINT, exit_handler)
  signal.signal(signal.SIGTERM, exit_handler)
  print('Press Ctrl+C to exit')

  serverPort = args.port
  tlsEnabled = args.tls
  scheme = 'http'

  while True: 
    webServer = HTTPServer((serverHost, serverPort), MyServer)
    if tlsEnabled: 
      webServer.socket = ssl.wrap_socket(webServer.socket, 
        keyfile=args.keyfile, 
        certfile=args.certfile, server_side=True)
      scheme = 'https'

    logging.info('Server started %s://%s:%s/' % (scheme, serverHost or 'localhost', serverPort))

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