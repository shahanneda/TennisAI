from http.server import HTTPServer, BaseHTTPRequestHandler

from io import BytesIO
import threading;
import json

motionData = ""

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Hello, world!')

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        # motionData = json.loads(body)
        proccess_motion_data(body.decode())

        self.send_response(200)
        self.end_headers()
        response = BytesIO()
        response.write(b'This is POST request. ')
        self.wfile.write(response.getvalue())



def proccess_motion_data(data):
    print(data)
    motionData = json.loads(data)
    print("new motiondata\n", motionData[0]["time"])


def start_server():
    httpd = HTTPServer(('', 3000), SimpleHTTPRequestHandler)
    httpd.serve_forever()
    server.serve_forever()

threading.Thread(target=start_server).start()

while(True):
    inputTyped = input("Enter Command: ")
    if(inputTyped == "motion"):
        print("here is motion data:\n" , motionData)

