from http.server import HTTPServer, BaseHTTPRequestHandler

from io import BytesIO
import threading;
import json
import matplotlib.pyplot as plt

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
    global motionData;
    motionData = json.loads(data)


def start_server():
    httpd = HTTPServer(('', 3000), SimpleHTTPRequestHandler)
    httpd.serve_forever()
    server.serve_forever()

threading.Thread(target=start_server).start()

def format_data():
    times = []
    ax = []
    ay = []
    az = []
    for point in motionData:
        times.append(point["time"])
        ax.append(point["ax"])
        ay.append(point["ay"])
        az.append(point["az"])
    
    plotData(times, ax, ay, az)



def plotData(times, ax, ay, az):
    plt.close()
    plt.plot(times, ax, 'o', color='black', label="x acceleration");
    plt.plot(times, ay, 'o', color='red', label="y acceleration");
    plt.plot(times, az, 'o', color='blue', label="z acceleration");
    plt.legend()
    plt.show()



while(True):
    inputTyped = input("Enter Command: ")
    if(inputTyped == "motion"):
        print("here is motion data:\n" , motionData)
    if(inputTyped == "mlen"):
        print("here is motion data points:\n" , len(motionData))
    if(inputTyped == "f"):
        format_data()

