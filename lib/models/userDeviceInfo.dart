// ignore_for_file: file_names

class UserDeviceInfo {
  /// System-Platform
  String platformStr = '';

  /// System-Version
  String platformVersion = '';

  /// Model
  String model = '';

  /// App-Version
  String appVersion = '';

  /// App build Version
  String appBundle = '';
  String packageName = '';

  /// App installed from which app store
  String installerStore = '';

  /// app 名字 由 packageName 和 appBundle 组成 ，故不需要 toString。     '${packageName}_$appBundle'
  String appName = '';

  /// 设备类型，phone,pad等
  String idiom = '';

  /// 设备品牌
  String vender = '';

  UserDeviceInfo(
      {this.platformStr = '',
        this.platformVersion = '',
        this.model = '',
        this.appVersion = '',
        this.appBundle = '',
        this.packageName = '',
        this.installerStore = '',
        this.appName = '',
        this.idiom = '',
        this.vender = ''});

  @override
  String toString() {
    return 'UserDeviceInfo:'
        'platformStr=$platformStr, '
        'platformVersion=$platformVersion, '
        'model=$model, '
        'appVersion=$appVersion, '
        'appBundle=$appBundle, '
        'packageName=$packageName, '
        'installerStore=$installerStore, '
        'idiom=$idiom, '
        'vender=$vender';
  }
}
