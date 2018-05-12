import UIKit
import CFoundry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let account = Session.account() {
            CFApi.login(account: account) { error in
                if error == nil {
                    let _ = self.showAppsScreen()
                }
            }
        }
        
        return true
    }

    internal func showAppsScreen() -> AppsViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navController = storyboard.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
        let appsController = storyboard.instantiateViewController(withIdentifier: "AppsView") as! AppsViewController

        self.window!.rootViewController = navController
        
        navController.pushViewController(appsController, animated: false)
        
        return appsController
    }
}
