from http.server import HTTPServer, BaseHTTPRequestHandler

from io import BytesIO
import threading;
import json
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

motionData = ""

#this is just for letting the main thread know that data has updated(since main thread does not have it)
shouldReplotData = False

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
        global shouldReplotData
        shouldReplotData = True



def proccess_motion_data(data):
    global motionData
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
        times.append(point["time"] - motionData[0]["time"])
        ax.append(point["ax"])
        ay.append(point["ay"])
        az.append(point["az"])
    
    # plotData(times, ax, ay, az)
    plotData(times, ax, ay, az)



def plotData3D(times, ax, ay, az):
    # Create the figure
    fig = plt.figure()
    plot = fig.add_subplot(111, projection='3d')


    plot.scatter(ax, ay, az, c='r', marker='o')
    plot.set_xlabel('X-axis')
    plot.set_ylabel('Y-axis')
    plot.set_zlabel('Z-axis')


def plotData(times, ax, ay, az):
    plt.plot(times, ax, 'o', color='black', label="x acceleration");
    plt.plot(times, ay, 'o', color='red', label="y acceleration");
    plt.plot(times, az, 'o', color='blue', label="z acceleration");
    plt.legend()

def showPlot():
    plt.show()


def autoUpdatePlot():
    format_data()
    plt.show(block=False)
    global shouldReplotData
    while True:
        plt.pause(1)
        if(shouldReplotData):
            plt.close()
            format_data()
            plt.draw()
            shouldReplotData = False

while(True):
    inputTyped = input("Enter Command: ")
    if(inputTyped == "motion"):
        print("here is motion data:\n" , motionData)
    if(inputTyped == "mlen"):
        print("here is motion data points:\n" , len(motionData))
    if(inputTyped == "auto"):
        autoUpdatePlot()

    if(inputTyped == "f"):
        format_data()
        showPlot()

