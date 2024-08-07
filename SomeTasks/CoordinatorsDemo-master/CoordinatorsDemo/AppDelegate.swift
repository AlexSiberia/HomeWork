import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: UserEditCoordinator!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let navigationController = window?.rootViewController as? UINavigationController else { return true }
        let user = User(name: "Pavel Gurov", city: City(name: "Moscow"))
        
        coordinator = UserEditCoordinator(user: user,
                                          navigationController: navigationController)
        coordinator.start()
        return true
    }
}
