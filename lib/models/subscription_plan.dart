class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final Duration duration;
  final List<String> features;
  final bool isPopular;
  final bool includesAdFree;
  final bool includesProFeatures;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = '₹',
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.includesAdFree = true,
    this.includesProFeatures = false,
  });

  String get durationText {
    if (duration.inDays >= 365) {
      return '${(duration.inDays / 365).round()} year${duration.inDays >= 730 ? 's' : ''}';
    } else if (duration.inDays >= 30) {
      return '${(duration.inDays / 30).round()} month${duration.inDays >= 60 ? 's' : ''}';
    } else {
      return '${duration.inDays} days';
    }
  }

  String get priceText => '$currency${price.toStringAsFixed(0)}';

  String get pricePerMonth {
    final monthlyPrice = (price * 30) / duration.inDays;
    return '$currency${monthlyPrice.toStringAsFixed(0)}/month';
  }

  static List<SubscriptionPlan> getAvailablePlans() {
    return [
      SubscriptionPlan(
        id: 'ad_free_3m',
        name: 'Ad-Free Basic',
        description: 'Remove ads and enjoy uninterrupted experience',
        price: 99,
        duration: const Duration(days: 90),
        features: [
          'No Ads',
          'Basic Features',
          'Sync Across Devices',
        ],
        includesAdFree: true,
        includesProFeatures: false,
      ),
      SubscriptionPlan(
        id: 'pro_monthly',
        name: 'Pro Monthly',
        description: 'Full access to all premium features',
        price: 299,
        duration: const Duration(days: 30),
        features: [
          'No Ads',
          'All Premium Features',
          'Offline Mode',
          'Advanced Analytics',
          'Priority Support',
          'Sync Across Devices',
        ],
        isPopular: true,
        includesAdFree: true,
        includesProFeatures: true,
      ),
      SubscriptionPlan(
        id: 'pro_annual',
        name: 'Pro Annual',
        description: 'Best value - Save 72% with annual plan',
        price: 999,
        duration: const Duration(days: 365),
        features: [
          'No Ads',
          'All Premium Features',
          'Offline Mode',
          'Advanced Analytics',
          'Priority Support',
          'Sync Across Devices',
          'Exclusive Content',
        ],
        includesAdFree: true,
        includesProFeatures: true,
      ),
    ];
  }
}
