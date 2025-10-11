import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  late String? _currentBuildNumber;
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
    await getDeviceInfo();
  }

  int get remoteBuildNumber {
    return _remoteConfig.getInt("build_number");
  }

  bool get _isForceUpdate {
    return _remoteConfig.getBool("is_force_update");
  }

  Future<void> getDeviceInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _currentBuildNumber = packageInfo.buildNumber;
  }

  Future<bool> get isForceUpdateEnabled async {
    bool isNeedUpdate =
        int.tryParse(_currentBuildNumber ?? "1")! < remoteBuildNumber;
    return isNeedUpdate && _isForceUpdate;
  }
}
