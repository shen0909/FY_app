import 'package:dio/dio.dart';

class UpdatePageState {
  Map<String, dynamic>? updateInfo;
  bool isLoading = false;
  bool isDownloading = false;
  bool isInstalling = false;
  double downloadProgress = 0.0;
  String errorMessage = '';
  String? currentVersion;
  CancelToken? cancelToken;

  UpdatePageState() {
    ///Initialize variables
  }
}
