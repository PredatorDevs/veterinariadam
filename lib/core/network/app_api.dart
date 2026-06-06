import 'api_client.dart';
import 'api_config.dart';

class AppApi {
  static final client = ApiClient(baseUrl: ApiConfig.baseUrl);
}
