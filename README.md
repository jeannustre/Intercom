# Intercom

  

## Getting started

- Add the SPM package to your project dependencies :


### Create your Context model

```swift
import IntercomUtils

public struct  MyContext: IntercomContext {
    var someProperty: Bool
}
```

`IntercomContext` requires that your struct also conforms to `Codable`.

Make sure this struct is available to both your iOS and watchOS apps. This will be the main way of communicating a "state" between your apps. 

### iOS implementation

- Add the `IntercomPhone` product to your iOS app.

- If you're using an AppDelegate, create and store an `IntercomPhone` and activate it on launch :

```swift
let intercom = IntercomPhone<MyContext>()

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    intercom.activate()
}
```

- If you're using SwiftUI, make it a @StateObject and inject it into the environment : 

```swift
@main
struct TestChartsWatchApp: App {

    @StateObject var intercom = IntercomPhone<MyContext>()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(intercom)
                .onAppear { intercom.activate() }
        }
    }
}
```

Then, whenever you need to send some info to the watchOS app by updating the `IntercomContext`, you can access this property :

```swift
struct ContentView: View {

    @EnvironmentObject var intercom: IntercomPhone<MyContext>

    var body: some View {
        Button(action: {
            try? intercom.send(context: MyContext(someProperty: true))
        }, label: {
            Text("Send Context")
        })
    }
}
```

Make sure you only create one Intercom session per app, as activating and holding multiple references to a WCSession introduces undefined behaviour.

### watchOS implementation

- Add the `IntercomWatch` product to your watchOS app.



## IntercomPhone properties

- receivedContext (this is the `IntercomContext` protocol your custom context adopts)
- isComplicationEnabled()
- isPaired()
- isWatchAppInstalled()

## IntercomPhone methods

### Sending Context
```swift
let context = CustomContext(someProperty: true)
intercom.send(context: context)
```

### Sending Messages
```swift
let message = SomeCodable()
intercom.send(message: message)

## Reacting to custom commands

Let's say you have some data in your iOS app that you want to make available to the watchOS app, without sending it through the Context. 

In your iOS app, when the data is available, register a custom command handler on the intercom instance :

```swift
struct YourData: Codable { 
    var someProperty: String
} 

let commandName: String = "request_some_data"
let responseKey: String = "response"
intercom.registerCommandHandler(name: commandName, handler: { commandParameters in
    let encoded = try? JSONEncoder().encode(yourData)
    return [responseKey: encoded as Any]
})
```

`commandParameters` is a [String:Any] of Plist-type parameters sent by the counterpart app.
Return a [String:Any] containing your data with the key of your choice.
If you don't need to return any data (eg. this is a simple one-way command), return `nil`.

When your data is not available anymore or you want to stop responding to the custom command, de-register it :

```swift
let commandName: String = "request_some_data"
intercom.removeCommandHandler(name: commandName)
```

Note : registering a command handler with an already registered `name` will erase the previously registered command handler. 

Note : avoid registering command handlers with names `play_success` or `request_context_update`. Check `IntercomCommand` for a list of default commands. //TODO: prefix the default command keys so there's less chances of clashes.

On the watchOS side, do something like : 

```swift
    @State var fetchedData: YourData?
    @State var dataLoaded: Bool = false
    
    var body: some View {
        if !dataLoaded {
            loadingView
        } else {
            Text(fetchedData?.someProperty ?? "-")
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .onAppear {
                do {
                    try intercom.send(command: .custom(
                        name: "request_some_data",
                        parameters: [ // [String:Any] but remember this `Any` should conform to the Plist types
                            "some_param": "Some value"
                        ]
                    ), replyHandler: { response in
                        guard let data = response["response_key"] as? Data,
                              let decoded = try? JSONDecoder().decode(YourData.self, from: data) else {
                            // Handle coding/decoding/error handling as you see fit
                            return
                        }
                        self.fetchedData = decoded
                        self.dataLoaded = true
                    })
                }
            }
    }
```

