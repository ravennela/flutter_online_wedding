import 'package:flutter_online/core/config/flavor_config.dart';
import 'package:flutter_online/main.dart' as common;

void main() async {
  FlavorConfig.initialize(
    flavor: Flavor.qa,
    name: 'Meeveduka (QA)',
    baseUrl: 'https://springwedding-qa.up.railway.app', // Update with actual QA URL
    razorpayKey: 'rzp_test_qa_key', // Replace with real key
  );
  await common.runner();
}
