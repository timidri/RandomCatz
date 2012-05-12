class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # alert = UIAlertView.new
    # alert.message = "Hello World!"
    # alert.show
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = LolController.alloc.init
    @window.makeKeyAndVisible
    true
  end
end
