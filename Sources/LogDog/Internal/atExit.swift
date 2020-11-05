import Foundation

let atExit = Notification.Name("com.v2ambition.LogDog.atExit")

private enum Once {
    static let lazy: Void = {
        atexit {
            NotificationCenter.default.post(name: atExit, object: nil)
        }
    }()
}

func atExit(_ callback: @escaping () -> Void) {
    NotificationCenter.default.addObserver(forName: atExit, object: nil, queue: nil) { _ in
        callback()
    }
}
