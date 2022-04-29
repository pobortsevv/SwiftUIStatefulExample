//
//  CodeNotificationCenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 31.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import NotificationCenter

// MARK: - Notifications Methods

extension AuthorizationViewController: UNUserNotificationCenterDelegate {
	/// Получаю уведомление, когда приложение открыто
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															willPresent notification: UNNotification,
															withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .sound])
	}
	
	/// Функция выполняется, когда мы нажимаем на уведомление
	func userNotificationCenter(_ center: UNUserNotificationCenter,
															didReceive response: UNNotificationResponse,
															withCompletionHandler completionHandler: @escaping VoidClosure) {
		if let code = UIPasteboard.general.string {
			print(code)
		}
	}
	
	func sendNotification(code: String) {
		let content = UNMutableNotificationContent()
		content.title = "Your sms code"
		content.body = code
		content.sound = .default
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
		
		let request = UNNotificationRequest(identifier: "sms code", content: content, trigger: trigger)
		
		notificationCenter.add(request)
	}
}
