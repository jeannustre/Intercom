import SwiftUI
import IntercomUtils
import WatchConnectivity
import WatchKit

public class IntercomWatch<T: IntercomContext>: NSObject, ObservableObject, WCSessionDelegate, Intercom {
    
    public var session: WCSession
    @Published public var phoneContext: T?
    
    var activated: Bool = false
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    
    private init(session: WCSession) {
        self.session = session
        super.init()
    }
    
    public override convenience init() {
        self.init(session: .default)
    }
    
    public func activate() {
        session.delegate = self
        session.activate()
    }
    
//    public func updateApplicationContext() {
//        session.receivedApplicationContext
//    }
    
    public func askIfPhoneIsShowingControl(completion: @escaping (Bool?, IntercomWatchError?)->Void) {
        let message: [String:Any] = [
            "command": "askIsShowingControl"
        ]
        session.sendMessage(message, replyHandler: { response in
            print("Got response from phone: \(response)")
            if let isShowingControl = response["isShowingControl"] as? Bool {
                if isShowingControl {
                    completion(true, .alreadyShowingOnPhone)
                } else {
                    completion(false, nil)
                }
            } else {
                let error: String = response["error"] as? String ?? ""
                print("Response was error: <\(error)>")
                completion(nil, .textualError(error))
            }
        }, errorHandler: { error in
            print("Error sending validation message: \(error)")
            completion(nil, .textualError(error.localizedDescription))
        })
    }
//
//    public func readJWTFromContext(completion: @escaping (String?, String?)->Void) {
//
//    }
    
//    public func requestJWTFromPhone(completion: @escaping (String?, String?)->Void) {
//        if !activated {
//            shouldRequestJWTWhenActivating = true
//            requestJWTCompletionHandler = completion
//            return
//        }
//        session.sendMessage(["command":"jwt"], replyHandler: { response in
//            if let accessToken = response["access"] as? String,
//               let refreshToken = response["refresh"] as? String {
//                completion(accessToken, refreshToken)
//            } else {
//                completion(nil, nil)
//            }
//        }, errorHandler: { error in
//            completion(nil, error.localizedDescription)
//        })
//    }
    
    /// Decode a `PhoneAppContext` received from the phone.
//    private func decodeReceivedContext(context: [String:Any]) throws -> T? {
//        guard let data = appContext["context"] as? Data else {
//            print("????????? No context")
//            return nil
//        }
//        guard let context = try? decoder.decode(T.self, from: data) else {
//            print("????????????? Couldn't decode context")
//            return nil
//        }
//        print("Decoded received context: \(context)")
//        return context
//    }
    
    @MainActor
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .notActivated:
            activated = false
        case .inactive:
            // TODO: ? probably can be the same as .activated
            break
        case .activated:
            DispatchQueue.main.async {
                // self.phoneContext = self.decodeReceivedContext(session.receivedApplicationContext) ?? .init(navigating: false)
                self.activated = true
            }
        @unknown default:
            break
        }
        print("activation completed with state: \(activationState.rawValue), error: \(error?.localizedDescription ?? "none")")
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received message: \(message.debugDescription)")
      
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("received message data: \(String(data: messageData, encoding: .utf8) ?? "nil")")
    }
    
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Received user info on watch: \(userInfo)")
        if let command = userInfo["command"] as? String {
            switch command {
            case "closeQR":
//                (WKExtension.shared().visibleInterfaceController as? ControlController)?.shouldPopOnResume = true
//                (WKExtension.shared().visibleInterfaceController as? ControlController)?.pop()
                NotificationCenter.default.post(name: NSNotification.Name("closeQR"), object: nil, userInfo: nil)
            default:
                print("Unhandled command received from phone: \(command)")
                break
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Received application context: \(applicationContext)")
        DispatchQueue.main.async {
            do {
                let context: T = try self.decode(context: session.receivedApplicationContext)
                self.phoneContext = context
            } catch {
                print()
            }
        }
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sessionReachabilityDidChange"), object: nil, userInfo: nil)
    }
    
}
