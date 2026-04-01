import 'package:flutter_online/core/config/flavor_config.dart';
import 'package:flutter_online/main.dart' as common;

void main() async {
  FlavorConfig.initialize(
    flavor: Flavor.prod,
    name: 'Online Wedding',
    baseUrl: 'https://springwedding-prod.up.railway.app', // Update with actual Prod URL
    razorpayKey: 'rzp_live_prod_key', // Replace with real key
  );
  await common.runner();
}
