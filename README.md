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
