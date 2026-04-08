import 'package:flutter_online/core/config/flavor_config.dart';
import 'package:flutter_online/main.dart' as common;

void main() async {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    name: 'Meeveduka (DEV)',
    baseUrl: 'https://springwedding-dev.up.railway.app',
    razorpayKey: 'rzp_test_RtNLIrdQnUawTd', // Replace with real key
  );
  await common.runner();
}
