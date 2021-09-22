//
//  AppDelegate.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import UIKit
import UserNotifications
import BackgroundTasks

let bgTaskIdentifier = "com.AndreyBelov.DollarFeed.refresh"
var operationQueue = OperationQueue()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

        
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: bgTaskIdentifier)
       // Fetch no earlier than 12 hours from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 12)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
   
    func handleAppRefresh(task: BGAppRefreshTask) {
       // Schedule a new refresh task.
       scheduleAppRefresh()

       // Create an operation that performs the main part of the background task.
       let operation = Operation()//RefreshAppContentsOperation()/////////////////////////////////////////////////////////////////////////////////
       
       // Provide the background task with an expiration handler that cancels the operation.
       task.expirationHandler = {
          operation.cancel()
       }

       // Inform the system that the background task is complete
       // when the operation completes.
       operation.completionBlock = {
          task.setTaskCompleted(success: !operation.isCancelled)
            print("BG!!!!!")
       }

       // Start the operation.
       operationQueue.addOperation(operation)
     }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgTaskIdentifier, using: DispatchQueue.main) { task in
             self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if granted {
                print("Разрешение на отправку уведомлений получено!")
            } else {
                print("В разрешении на отправку уведомлений отказано!")
            }
        })
        
        let content = UNMutableNotificationContent()
        content.title = "Рубль рухнул!"
        content.body = "Курс доллара превысил заданное пороговое значение!"
        content.sound = UNNotificationSound.default
        let trigger  = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "ThresholdNotification", content: content, trigger: trigger)
        center.add(request)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

