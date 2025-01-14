import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController

        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // User is logged in, go to HomeViewController
            initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") // Replace "HomeViewController" with the actual identifier of your HomeViewController
        } else {
            // User is not logged in, go to SignInViewController
            initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") // Replace "SignInViewController" with the actual identifier of your SignInViewController
        }

        let navigationController = UINavigationController(rootViewController: initialViewController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
