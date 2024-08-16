import SwiftUI
import IntercomUtils
import WatchConnectivity
import WatchKit

public class IntercomWatch<T: IntercomContext>: NSObject, ObservableObject, WCSessionDelegate, Intercom {
    public let session: WCSession
        
    @Published public var receivedContext: T?
    @Published public var reachable: Bool = false
    
    public var deviceContext: T?
    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()
    public var canSend: Bool = false
    public var canReceive: Bool = false
    public weak var delegate: IntercomDelegate?
    
    public init(session: WCSession = .default) {
        self.session = session
        super.init()
    }
    
    public func activate() {
        DispatchQueue.main.async { [weak self] in
            guard WCSession.isSupported() else {
                return
            }
            self?.session.delegate = self
            self?.session.activate()
        }
    }

    public func perform(command: IntercomCommand) -> [String:Any]? {
        switch command {
        case IntercomCommand.playSuccess:
            WKInterfaceDevice.current().play(.success)
        case IntercomCommand.requestContextUpdate:
            // The phone asked the watch app to send its context.
//            if let deviceContext {
//                try? send(context: deviceContext)
//            }
            break
        case IntercomCommand.custom(let name, let parameters):
            print("Received custom command: \(name), \(parameters)")
        case IntercomCommand.analytic(let event, let parameters):
            print("Received analytic event: \(event), \(parameters) but this is watchOS so why ?")
        }
        return nil
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        switch activationState {
        case .activated:
            canSend = true
            canReceive = true
        case .inactive:
            canSend = false
            canReceive = true
        case .notActivated:
            canSend = false
            canReceive = false
        }
        reachable = session.isReachable
    }
    
    //MARK: - Receiving Messages
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print()
//        delegate?.session(didReceiveMessage: message, replyHandler: replyHandler)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print()
//        delegate?.session(didReceiveMessage: message)
    }
    
    //MARK: - Receiving Context
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.receivedContext = try? self.decode(context: applicationContext)
        }
    }
    
    //MARK: - Reachability
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        print()
//        delegate?.reachabilityChanged(reachable: session.isReachable)
    }

}
