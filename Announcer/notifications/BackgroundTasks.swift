//
//  BackgroundTasks.swift
//  Announcer
//
//  Created by Ayaan Jain on 20/3/23.
//

import Foundation
import UIKit //hehe
import SwiftUI
import BackgroundTasks
import PostManager
import UserNotifications




@main
struct YourApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Application did launch")

        // Request authorization for local and remote notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else {
                print("Notification authorization granted: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    DispatchQueue.main.async {
                        guard let window = UIApplication.shared.windows.first(where: \.isKeyWindow),
                              let rootViewController = window.rootViewController else {
                            return
                        }
                        let alertController = UIAlertController(title: "Notification Authorization Required",
                                                                message: "Please enable notification permissions in Settings to receive notifications from this app.",
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        rootViewController.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }

        application.registerForRemoteNotifications()

        // Schedule app refresh task
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule the task for 15 minutes from now
            do {
                try BGTaskScheduler.shared.submit(request)
                print("App refresh task scheduled successfully")
            } catch {
                print("Unable to schedule app refresh task: \(error)")
            }
        }

        return true
    }
    
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
        request.earliestBeginDate = .now.addingTimeInterval(24 * 3600)
        
        try? BGTaskScheduler.shared.submit(request)
        
        do {
            let fetchedItems = try PostManager.fetchValues(range: 0..<10)
            let diff = PostManager.addPostsToStorage(newItems: fetchedItems)
            if diff > 0 {
                let content = UNMutableNotificationContent()
                content.title = "New Posts Available"
                content.body = "\(diff) new posts are available"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
        catch {
            print("An error occured: \(error)")
        }
    }
    
    func handle(task: BGAppRefreshTask) {
        // Handle the app refresh task here
        task.expirationHandler = {
            // Handle task expiration if needed
        }
        
        // Create a new instance of the task to start it again after it finishes
        let newTask = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
        newTask.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    }
    
    
}