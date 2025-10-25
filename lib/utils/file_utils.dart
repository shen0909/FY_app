// 文件工具类，用于获取公共目录路径
import 'package:path_provider/path_provider.dart';
import 'package:safe_app/utils/toast_util.dart';

class FileUtil {
  /// 获取公共下载目录的路径。
  /// 如果权限未授予或目录不可用，将返回 null。
  static Future<String?> getDownloadDirectoryPath() async {
    // // 请求存储权限
    // var status = await Permission.storage.request();
    // if (!status.isGranted) {
    //   ToastUtil.showShort('未授予存储权限', title: '错误');
    //   return null;
    // }
    // 尝试获取公共下载目录
    var directory = await getDownloadsDirectory();
    if (directory == null) {
      ToastUtil.showShort('无法获取公共下载目录', title: '错误');
      return null;
    }
    return directory.path;
  }
}