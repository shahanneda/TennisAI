//
//  InterfaceController.swift
//  TennisAI WatchKit Extension
//
//  Created by Shahan Nedadahandeh on 2020-11-28.
//  Copyright © 2020 Shahan Nedadahandeh. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import os

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    
    var motionData: [TennisMotionData] = []

    var timer: Timer?

    let motionManager = CMMotionManager()


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.motionData.append(TennisMotionData(time: 10330.44, ax: 44.44, ay:44, az:44));
    }
    
    // Just sends a post request to the server with the data from the last run
    @IBAction func ButtonClicked() {
        self.motionData.append(TennisMotionData(time: 10330.44, ax: 44.44, ay:44, az:44));
        print("button clicked");
//        let stringMotionData = "[{t:10330.709125250001, z: -0.010376915335655212, y: 0.009768351912498474, z: 0.002002537250518799},{t:10330.719043250001, z: -0.007614761590957642, y: 0.012676745653152466, z: 0.003616809844970703},{t:10330.72899225, z: 0.07062597572803497, y: -0.06545883417129517, z: 1.0311317443847656},{t:10330.738941250002, z: -0.05473095178604126, y: 0.4297013580799103, z: -0.7311424016952515},{t:10330.748859250001, z: -0.2883108854293823, y: -0.08755229413509369, z: 0.2589813470840454},{t:10330.75880825, z: 0.13480186462402344, y: -0.20390388369560242, z: -0.06482374668121338},{t:10330.76872625, z: 0.1193186342716217, y: -0.14377851784229279, z: -0.25198638439178467},{t:10330.778675250001, z: 0.06138224899768829, y: -0.08423644304275513, z: -0.11901122331619263},{t:10330.788593250001, z: 0.040999606251716614, y: -0.058723047375679016, z: -0.1768314242362976},{t:10330.79854225, z: 0.03338758647441864, y: -0.07599668204784393, z: -0.1356590986251831},{t:10330.80846025, z: 0.05921943485736847, y: -0.06514614820480347, z: -0.07402706146240234},{t:10330.818409250001, z: 0.00911395251750946, y: -0.020980611443519592, z: 0.06416845321655273},{t:10330.82835725, z: -0.06835198402404785, y: 0.1414075791835785, z: 0.03762948513031006},{t:10330.83827625, z: 0.0016039460897445679, y: 0.17856210470199585, z: 0.06787246465682983}]"

        let url = URL(string: "http://192.168.1.99:3000")!
//        let json = ["data": motionData]
//        let jsonData = try? JSONSerialization.data(withJSONObject: motionData)
//
        let jsonEncoder = JSONEncoder()
        let jsonEncoded = try? jsonEncoder.encode(motionData)
        motionData.removeAll();
//        let json = String(data: jsonEncoded!, encoding: String.Encoding.utf16)
//        let jsonData = try? JSONSerialization.data(withJSONObject: json!)

        print(motionData);
        print(jsonEncoded!.base64EncodedString());

        // create post request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(String(describing: jsonEncoded?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // insert json data to the reques
        request.httpBody = jsonEncoded

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON) //Code after Successfull POST Request
            }
        }

        task.resume()
    }

    
   
    override func willActivate() {
        super.willActivate()
        print("got here actiavte")
        if motionManager.isDeviceMotionAvailable {
            let coreMotionHandler : CMDeviceMotionHandler = {(data: CMDeviceMotion?, error: Error?) -> Void in
                // do something with data!.userAcceleration
                // data!. can be used to access all the other properties mentioned above. Have a look in Xcode for the suggested variables or follow the link to CMDeviceMotion I have provided
                let x = data!.userAcceleration.x;
                let y = data!.userAcceleration.y;
                let z = data!.userAcceleration.z;
                let time = data!.timestamp;


                print("{X: \(x), Y: \(y), Z: \(z)}")
//                self.labelX.setText(String(format: "%.2f", data!.userAcceleration.x))
//                self.labelY.setText(String(format: "%.2f", data!.userAcceleration.y))
//                self.labelZ.setText(String(format: "%.2f", data!.userAcceleration.z))


                self.motionData.append(TennisMotionData(time: time, ax: x, ay:y, az:z))
            }
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: coreMotionHandler)
        }
    }
    
    override func didDeactivate() {
        print("got here did diactivarte")
        super.didDeactivate()
        motionManager.stopDeviceMotionUpdates()
    }
        
    func logError(_ msg: StaticString, _ params: Any...) {
        os_log(msg, log: OSLog.default, type: .error, params)
    }
}
    
struct TennisMotionData: Codable {
    var time: TimeInterval
    var ax: Double
    var ay: Double
    var az: Double
}
