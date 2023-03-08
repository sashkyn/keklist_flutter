import UIKit
import Flutter
import WatchConnectivity

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var watchSession: WCSession?
    
    private lazy var flutterMethodChannel: FlutterMethodChannel = {
        let controller = window?.rootViewController as! FlutterViewController
        return FlutterMethodChannel(
            name: "com.sashkyn.kekable",
            binaryMessenger: controller.binaryMessenger
        )
    }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
        
        // MARK: Activation Apple Watch Session
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession?.delegate = self
            watchSession?.activate()
        }
        
        // MARK: Registation method channel
        
        flutterMethodChannel.setMethodCallHandler { [weak self] call, result in
            // TODO: проверить является ли метод поддерживаемым часами через enum
            //let method = call.method
            
            let args = call.arguments
            
            guard let watchSession = self?.watchSession,
                  watchSession.isPaired,
                  let messageData = (args as? Array<Any>)?.first as? [String: Any] else {
                print("watch not paired")
                return
            }
            
            guard watchSession.isReachable else {
                print("watch not reachable")
                return
            }
            
            // TODO: отправлять название метода тоже
            watchSession.sendMessage(messageData, replyHandler: nil)
        }
        
        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
  }
}

extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("AppDelegate WC: activationDidCompleteWith - \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate WC: sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate WC: sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("AppDelegate WC: session didReceiveMessage - \(message)")
        
        guard let methodName = message["method"] as? String else {
            return
        }
        
        let arguments = message["data"] as? [String : Any]
        flutterMethodChannel.invokeMethod(methodName, arguments: arguments)
    }
}
