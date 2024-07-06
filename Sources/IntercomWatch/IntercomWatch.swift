import SwiftUI
import IntercomUtils
import WatchConnectivity
import WatchKit

public class IntercomWatch<T: IntercomContext>: NSObject, ObservableObject, WCSessionDelegate, Intercom {
    
    @Published public var receivedContext: T?
    public var session: WCSession
    public var activated: Bool = false
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
                self.receivedContext = try? self.decode(context: session.receivedApplicationContext)
                self.activated = true
            }
        @unknown default:
            break
        }
        print("activation completed with state: \(activationState.rawValue), error: \(error?.localizedDescription ?? "none")")
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("received message with no awaited response: \(message.debugDescription)")
        if let command = tryParsingCommand(message: message) {
            perform(command: command)
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received messagewith awaited response: \(message.debugDescription)")
        if let command = tryParsingCommand(message: message) {
            perform(command: command)
        }
    }
    
    private func tryParsingCommand(message: [String:Any]) -> IntercomCommand? {
        guard let rawValue = message[IntercomKey.command.rawValue] as? String else { return nil }
        return IntercomCommand(rawValue: rawValue)
    }
    
    private func perform(command: IntercomCommand) {
        switch command {
        case .playSuccess:
            WKInterfaceDevice.current().play(.success)
            print("BZZZ")
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let message = String(data: messageData, encoding: .utf8) else {
            //TODO: exception "empty message" ?
            return
        }
        print("Unhandled message data: \(message)")
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
            self.receivedContext = try? self.decode(context: session.receivedApplicationContext)
        }
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sessionReachabilityDidChange"), object: nil, userInfo: nil)
    }
    
}
