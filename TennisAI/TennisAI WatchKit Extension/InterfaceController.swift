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
import HealthKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    
    let maxDataPoints = 1000;
    var motionData: [TennisMotionData] = []

    var timer: Timer?

    let motionManager = CMMotionManager()

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
//        self.motionData.append(TennisMotionData(time: 10330.44, ax: 44.44, ay:44, az:44));
        setupHealthKitSession();
    }
    
    // just doing this session since we still neeed to motion data when the watch face is off, however we dont actualyl need any of the data
    func setupHealthKitSession(){
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
//
//        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,

        ]
//
//
        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
        }
        
        // Handle error.
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor
        
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }

        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
        }
        
        // TODO: Refactor this functino to its own class so we we can assign delegates and actually collect data
//        session.delegate = self
//        builder.delegate = self

    }
    
    
    // Just sends a post request to the server with the data from the last run
    @IBAction func ButtonClicked() {
        print("button clicked");

        let url = URL(string: "http://192.168.1.99:3000")!
//        let json = [data": motionData]
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


                if(self.motionData.count > self.maxDataPoints){
                    self.motionData.removeFirst()
                }
                self.motionData.append(TennisMotionData(time: time, ax: x, ay:y, az:z))
            }
            
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: coreMotionHandler)
        }
    }
    
    override func didDeactivate() {
        print("got here did diactivarte")
        super.didDeactivate()
        motionManager.stopDeviceMotionUpdates()
        builder.endCollection(withEnd: Date()) { (success, error) in
            self.builder.finishWorkout { (workout, error) in
                print("finished health kit session")
            }
        }

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
