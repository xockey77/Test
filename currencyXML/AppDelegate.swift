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

var operationQueue = OperationQueue()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    class RefreshAppContentsOperation: Operation {
        
    }
        
    func scheduleAppRefresh() {
        os_log("scheduleAppRefresh exetued.")
       let request = BGAppRefreshTaskRequest(identifier: "com.AndreyBelov.DollarFeed.refresh")
       request.earliestBeginDate = Date(timeIntervalSinceNow: 600)
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
   
    func handleAppRefresh(task: BGAppRefreshTask) {

        scheduleAppRefresh()
        let operation = RefreshAppContentsOperation() //TODO засунуть получение данных в operation, пока без нее
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
        task.expirationHandler = {
          operation.cancel()
        }

        operation.completionBlock = {
           task.setTaskCompleted(success: !operation.isCancelled)
           os_log("Background task is complete!)")
        }
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
        center.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, error) in
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

