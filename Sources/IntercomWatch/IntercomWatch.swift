import SwiftUI
import IntercomUtils
import WatchConnectivity
import WatchKit

public class IntercomWatch<T: IntercomContext>: ObservableObject, Intercom {
        
    @Published public var receivedContext: T?
    @Published public var reachable: Bool = false
    public var deviceContext: T?
//    public var activated: Bool = false
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    
    public var session: IntercomSession = IntercomSession(session: .default)
    
    public init() {
        
    }
    
    public func activate() {
        session.delegate = self
        session.activate()
    }
    
//    public func askIfPhoneIsShowingControl(completion: @escaping (Bool?, IntercomWatchError?)->Void) {
//        let message: [String:Any] = [
//            "command": "askIsShowingControl"
//        ]
//        session.sendMessage(message, replyHandler: { response in
//            print("Got response from phone: \(response)")
//            if let isShowingControl = response["isShowingControl"] as? Bool {
//                if isShowingControl {
//                    completion(true, .alreadyShowingOnPhone)
//                } else {
//                    completion(false, nil)
//                }
//            } else {
//                let error: String = response["error"] as? String ?? ""
//                print("Response was error: <\(error)>")
//                completion(nil, .textualError(error))
//            }
//        }, errorHandler: { error in
//            print("Error sending validation message: \(error)")
//            completion(nil, .textualError(error.localizedDescription))
//        })
//    }

    public func perform(command: IntercomCommand) {
        switch command {
        case .playSuccess:
            WKInterfaceDevice.current().play(.success)
            print("BZZZ")
        case .requestContextUpdate:
            // The phone asked the watch app to send its context.
//            if let deviceContext {
//                try? send(context: deviceContext)
//            }
            break
        }
    }
    
    public func send<E>(context: E) throws where E : Encodable {
        try session.send(context: context)
    }
    
    public func send(command: IntercomUtils.IntercomCommand, replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((any Error) -> Void)? = nil) throws {
        try session.send(command: command, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
//    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
//        guard let message = String(data: messageData, encoding: .utf8) else {
//            //TODO: exception "empty message" ?
//            return
//        }
//        print("Unhandled message data: \(message)")
//    }
//    
//    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
//        print("Received user info on watch: \(userInfo)")
//        if let command = userInfo["command"] as? String {
//            switch command {
//            case "closeQR":
////                (WKExtension.shared().visibleInterfaceController as? ControlController)?.shouldPopOnResume = true
////                (WKExtension.shared().visibleInterfaceController as? ControlController)?.pop()
//                NotificationCenter.default.post(name: NSNotification.Name("closeQR"), object: nil, userInfo: nil)
//            default:
//                print("Unhandled command received from phone: \(command)")
//                break
//            }
//        }
//    }

}


extension IntercomWatch: IntercomSession.Delegate {
    
    public func activationStatusChanged(canSend: Bool, canReceive: Bool) {
        
    }
    
    public func reachabilityChanged(reachable: Bool) {
        
    }
    
    public func session(didReceiveMessage message: [String : Any]) {
        if let command = IntercomCommand(message: message) {
            perform(command: command)
        }
    }
    
    public func session(didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = IntercomCommand(message: message) {
            perform(command: command)
        }
    }
    
    public func session(didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.receivedContext = try? self.decode(context: applicationContext)
        }
    }
    
}
