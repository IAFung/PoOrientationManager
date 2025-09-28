# PoOrientationManager
ios rotation manager
设置步骤
## 1
`didFinishLaunchingWithOptions`设置`UIViewController.orientationInitial()`
## 2 
```
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
```
## 3
要旋转的viewController设置为
```
 override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        poCurrentSupportedInterfaceOrientations
    }
```
如果进入时为横屏,设置
```
override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        poDevicePreferredHorizontalInterfaceOrientation
    }
```
## 4
当前页面切换横竖屏:
```
 PoOrientationManager.shared.set(poDevicePreferredHorizontalInterfaceOrientation)
PoOrientationManager.shared.set(.portrait)
```
当前页面切换为仅支持横屏或竖屏:
```
poSupportedInterfaceOrientations = .allButUpsideDown
poSupportedInterfaceOrientations = .portrait
```
