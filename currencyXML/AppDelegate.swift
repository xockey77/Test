//
//  AppDelegate.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import UIKit
import UserNotifications
import BackgroundTasks

//let bgTaskIdentifier = "com.AndreyBelov.DollarFeed.refresh"

var operationQueue = OperationQueue()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    class RefreshAppContentsOperation: Operation {
        
    }
        
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: "com.AndreyBelov.DollarFeed.refresh")
       // Fetch no earlier than 12 hours from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
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
        print("operation = RefreshAppContentsOperation()")
       
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
        
        
        window = UIWindow.init()
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
        window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()

 
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.AndreyBelov.DollarFeed.refresh", using: nil) { task in
            print("self.handleAppRefresh(task: task as! BGAppRefreshTask)")
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
            //BackgroundScheduler.shared.handleAppRefresh(task: task as! BGAppRefreshTask)
            print("self.handleAppRefresh(task: task as! BGAppRefreshTask)")
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
    
    func applicationDidEnterBackground (_ application: UIApplication) {
        print("applicationDidEnterBackground")
        scheduleAppRefresh()
    }
    /*
     import Foundation
     import BackgroundTasks
     import os

     class BackgroundScheduler {
         
         let backgroundTaskId = "com.amirrezaeghtedari.coronaVirousRegulations.incidents.fetch"
         
         static let shared = BackgroundScheduler()
         
         private var operation: BackgroundFetchOperation = {
             
             let locationProvider             = LocationProvider()
             let incidentsAPIProvider         = IncidentsAPIProvider()
             let networkLoader                 = NetworkLoader()
             let incidentsProvider             = IncidentsProviderMock(apiProvider: incidentsAPIProvider, networkLoader: networkLoader)
             let entityProvider                = EntityProvider()
             let threatColorStoreProvider     = ThreatColorStoreProvider()
             let localNotificationProvider   = LocalNotificationProvider()
             
             let operation = BackgroundFetchOperation(locationProvider: locationProvider, incidentsProvider: incidentsProvider, entityProvider: entityProvider, threatColorStoreProvider: threatColorStoreProvider, localNotificationProvider: localNotificationProvider)
             
             locationProvider.delegate             = operation
             localNotificationProvider.delegate     = operation
             
             return operation
         }()
         
         private init() {}
         
         func scheduleAppRefresh() {
             
             os_log("scheduleAppRefresh exetued.")
             
             let request = BGAppRefreshTaskRequest(identifier: backgroundTaskId)
             request.earliestBeginDate = Date(timeIntervalSinceNow: AppSettings.refreshInterval)

             do {
                 try BGTaskScheduler.shared.submit(request)
             } catch {
                 os_log("Could not schedule app refresh:", error.localizedDescription)
             }
         }
         
         func handleAppRefresh(task: BGAppRefreshTask) {
             
             os_log("handleAppRefresh exetued.")
             
             scheduleAppRefresh()
             
             operation.fetch() {success in
                 os_log("backgroundFetch expiration called")
                 task.setTaskCompleted(success: success)
             }
         }
     }
     
     func fetch(completion: @escaping Completion) {

             self.completion = completion
             locationRrovider.requestCoordinate(locationIncidator: true)
         }
     
     func requestCoordinate(locationIncidator: Bool){
             
             DispatchQueue.main.async { [weak self] in
                 
                 self?.locationManager?.showsBackgroundLocationIndicator = locationIncidator
                 self?.locationManager?.requestLocation()
             }
         }
     }
     
     func loadRequest(request: URLRequest, modelID: String?, timeout: Double, completion: Completion?) {
             
             if !isInternetConnected() {
                 
                 completion?(Result.failure(NetworkError(
                                     errorKind: .internetIsNotConnected,
                                     modelID: nil)))
                 return
             }
             
             urlSession.configuration.timeoutIntervalForRequest = timeout
             
             let task = urlSession.dataTask(with: request) { (data, response, error) in
                 
                 self.completionHandler(data: data, response: response, error: error, completion: completion, modelID: modelID)
             }
             
             task.resume()
         }
     
     func completionHandler(data:Data?, response: URLResponse?, error: Error?, completion: Completion?, modelID: String?) {
             
             guard error == nil else {
                 completion?(Result.failure(NetworkError(errorKind: .unableToComplete, modelID: modelID)))
                 return
             }
             
             if let response = response as? HTTPURLResponse, response.statusCode != 200  {
                 completion?(Result.failure(NetworkError(errorKind: .invalidResponse(response.statusCode), modelID: modelID)))
                 return
             }
             
             guard let data = data else {
                 completion?(Result.failure(NetworkError(errorKind: .invalidData(nil), modelID: modelID)))
                 return
             }
             
             completion?(Result.success((data,modelID)))
         }
     */
     
    /*
    func sceneDidEnterBackground(_ scene: UIScene) {
                    
         BackgroundScheduler.shared.scheduleAppRefresh()
    }
    */

    
    // MARK: UISceneSession Lifecycle
    /*
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
*/

}

