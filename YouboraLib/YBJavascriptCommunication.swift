//
//  YBJavascriptCommunication.swift
//  YouboraLib
//
//  Created by nice on 03/02/2020.
//  Copyright © 2020 NPAW. All rights reserved.
//

import UIKit

private struct NotificationName {
    static let jsInjection = NSNotification.Name(rawValue: YBConstants.jsInjectionNotification)
}

private struct JSCommands {
    static let sharedSessionRoot = "window.sharedSessionRoot"
}

/**
* This class encapsulates the communications with js plugin
* In order to use this class the user should change the options jsCommunication as true
* it will make the communications throught NotificationCenter
*/
@objcMembers public class YBJavascriptCommunication: NSObject {

    private static var registerdObservers: [NSNotification.Name] = []

    private static var observersAvailable: Bool {
        return registerdObservers.count > 0
    }

    /**
     Register a new observer to get js string to be injected in a webview
    - Parameters:
        - observer: instance that will receive the js strigs to inject
        - selector:selector method where a Dictionary( or NSDictionary case Objc) will be sent through a NSNotification
            To get the command type to inject you can use the key YBConstants.jsKeyInjectionType then you can compare with all YBJSInjectionType
            values to check which value it is
            To get the code to inject you can use the key YBConstants.jsKeyInjectionCode
    */
    public static func registerObserver(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NotificationName.jsInjection, object: nil)
        registerdObservers.append(NotificationName.jsInjection)
    }

    /**
    Remove the observer to stop listening js injection notifications
    - Parameters:
        - observer: Observer to stop listening js injection notifications
    */
    public static func unregisterObserver(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: NotificationName.jsInjection, object: nil)
        registerdObservers.removeAll()
    }

    /**
    Method that will share session root with js, should be called every time a new session root is generated
    - Parameters:
        - sessionRoot: string with the new generated session root
    */
    public static func notifyNewSessionRoot(sessionRoot: String) {
        let jsString = JSCommands.sharedSessionRoot+" = '"+sessionRoot+"';"
        postNotificationWithJS(key: YBJSInjectionType.sessionRootInjection, jsToInject: jsString)
    }

    /**
    Build the object with the key and the js to be injected and post the notification with it
    - Parameters:
        - key: string that will identify which type of command is it (YBJSInjectionType)
        - jsToInject: string with the new generated session root
    */
    private static func postNotificationWithJS(key: String, jsToInject: String) {
        if observersAvailable {
            let objectToBeSent = [
                YBConstants.jsKeyInjectionType: key,
                YBConstants.jsKeyInjectionCode: jsToInject
            ]
            NotificationCenter.default.post(name: NotificationName.jsInjection, object: objectToBeSent)
        }
    }

}