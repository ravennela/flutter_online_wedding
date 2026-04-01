enum Flavor {
  dev,
  qa,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String baseUrl;
  final String razorpayKey;

  static FlavorConfig? _instance;

  FlavorConfig._internal(this.flavor, this.name, this.baseUrl, this.razorpayKey);

  static void initialize({
    required Flavor flavor,
    required String name,
    required String baseUrl,
    required String razorpayKey,
  }) {
    _instance = FlavorConfig._internal(flavor, name, baseUrl, razorpayKey);
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception("FlavorConfig must be initialized with a flavor");
    }
    return _instance!;
  }

  static bool get isDev => instance.flavor == Flavor.dev;
  static bool get isQa => instance.flavor == Flavor.qa;
  static bool get isProd => instance.flavor == Flavor.prod;
}
