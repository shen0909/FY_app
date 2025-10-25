import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var securityView: UIView?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 注册应用生命周期监听
    setupSecurityNotifications()
    
    // 注册截屏监听
    setupScreenshotNotification()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - 安全防护相关方法
  
  /// 设置应用生命周期监听
  private func setupSecurityNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  /// 设置截屏监听
  private func setupScreenshotNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }
  
  /// 应用即将失去焦点
  @objc private func applicationWillResignActive() {
    addSecurityView()
  }
  
  /// 应用获得焦点
  @objc private func applicationDidBecomeActive() {
    removeSecurityView()
  }
  
  /// 应用进入后台
  @objc private func applicationDidEnterBackground() {
    addSecurityView()
  }
  
  /// 应用即将进入前台
  @objc private func applicationWillEnterForeground() {
    removeSecurityView()
  }
  
  /// 用户截屏
  @objc private func userDidTakeScreenshot() {
    print("警告：检测到用户尝试截屏")
    // 这里可以添加额外的处理逻辑，比如显示警告弹窗
    // 但由于前面已经添加了遮罩视图，截屏内容会被遮挡
  }
  
  /// 添加安全遮罩视图
  private func addSecurityView() {
    guard securityView == nil,
          let window = UIApplication.shared.windows.first else { return }
    
    securityView = UIView(frame: window.bounds)
    securityView?.backgroundColor = UIColor.white
    
    // 添加应用图标或其他占位内容
    let imageView = UIImageView()
    imageView.image = UIImage(named: "AppIcon") // 确保有应用图标
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    securityView?.addSubview(imageView)
    window.addSubview(securityView!)
    
    // 设置约束
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: securityView!.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: securityView!.centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 120),
      imageView.heightAnchor.constraint(equalToConstant: 120)
    ])
  }
  
  /// 移除安全遮罩视图
  private func removeSecurityView() {
    securityView?.removeFromSuperview()
    securityView = nil
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
