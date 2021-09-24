//
//  AppDelegate.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import UIKit
import UserNotifications
import BackgroundTasks
import os

//let bgTaskIdentifier = "com.AndreyBelov.DollarFeed.refresh"

var operationQueue = OperationQueue()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    class RefreshAppContentsOperation: Operation {
        
    }
        
    func scheduleAppRefresh() {
        os_log("scheduleAppRefresh exetued.")
       let request = BGAppRefreshTaskRequest(identifier: "com.AndreyBelov.DollarFeed.refresh")
       // Fetch no earlier than 12 hours from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 600)
       do {
          try BGTaskScheduler.shared.submit(request)
        print("scheduleAppRefresh")
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
   
    func handleAppRefresh(task: BGAppRefreshTask) {
       // Schedule a new refresh task.
        print("handleAppRefresh")
       scheduleAppRefresh()

       // Create an operation that performs the main part of the background task.
       let operation = RefreshAppContentsOperation()/////////////////////////////////////////////////////////////////////////////////
        //print("operation = RefreshAppContentsOperation()")
    
        let network = Network()
        network.fetchData { (result) in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                    TableViewController.shared.updateUI(with: data)
                    }
                case .failure(let error):
                    print(error)
                }
        }
       // Provide the background task with an expiration handler that cancels the operation.
       task.expirationHandler = {
          operation.cancel()
       }

       // Inform the system that the background task is complete
       // when the operation completes.
        
       operation.completionBlock = {
          task.setTaskCompleted(success: !operation.isCancelled)
            print("BG!!!!!")
           /*
           let content = UNMutableNotificationContent()
           content.title = "Рубль рухнул!"
           content.body = "Курс доллара превысил заданное пороговое значение!"
           content.sound = UNNotificationSound.default
           let trigger  = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
           let request = UNNotificationRequest(identifier: "ThresholdNotification", content: content, trigger: trigger)
           let center = UNUserNotificationCenter.current()
           center.add(request)*/
       }

       // Start the operation.
       operationQueue.addOperation(operation)
     }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init()
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.AndreyBelov.DollarFeed.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if granted {
                os_log("Разрешение на отправку уведомлений получено!")
            } else {
                os_log("В разрешении на отправку уведомлений отказано!")
            }
        })
        return true
    }
    
    func applicationDidEnterBackground (_ application: UIApplication) {
        os_log("applicationDidEnterBackground")
        scheduleAppRefresh()
    }

}

