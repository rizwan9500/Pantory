import 'package:flutter_test/flutter_test.dart';
import 'package:pantory/models/user_model.dart';
import 'package:pantory/models/subscription_plan.dart';

void main() {
  group('UserModel Tests', () {
    test('User model creation', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        isTrialActive: true,
        trialEndDate: DateTime.now().add(const Duration(days: 7)),
        subscriptionStatus: SubscriptionStatus.trial,
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.isTrialActive, true);
      expect(user.subscriptionStatus, SubscriptionStatus.trial);
    });

    test('User has active subscription when on trial', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        isTrialActive: true,
        subscriptionStatus: SubscriptionStatus.trial,
      );

      expect(user.hasActiveSubscription, true);
    });

    test('User has active subscription when Pro', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        subscriptionStatus: SubscriptionStatus.active,
      );

      expect(user.hasActiveSubscription, true);
      expect(user.isPro, true);
    });

    test('Trial days remaining calculation', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        isTrialActive: true,
        trialEndDate: DateTime.now().add(const Duration(days: 5)),
        subscriptionStatus: SubscriptionStatus.trial,
      );

      expect(user.trialDaysRemaining, greaterThanOrEqualTo(4));
    });
  });

  group('SubscriptionPlan Tests', () {
    test('Get available plans', () {
      final plans = SubscriptionPlan.getAvailablePlans();

      expect(plans.length, 3);
      expect(plans[0].id, 'ad_free_3m');
      expect(plans[1].id, 'pro_monthly');
      expect(plans[2].id, 'pro_annual');
    });

    test('Plan pricing is correct', () {
      final plans = SubscriptionPlan.getAvailablePlans();
      
      expect(plans[0].price, 99);
      expect(plans[1].price, 299);
      expect(plans[2].price, 999);
    });

    test('Pro monthly is marked as popular', () {
      final plans = SubscriptionPlan.getAvailablePlans();
      
      expect(plans[1].isPopular, true);
    });

    test('Plan duration text is correct', () {
      final plans = SubscriptionPlan.getAvailablePlans();
      
      expect(plans[0].durationText, '3 months');
      expect(plans[1].durationText, '1 month');
      expect(plans[2].durationText, '1 year');
    });

    test('Price per month calculation', () {
      final annualPlan = SubscriptionPlan.getAvailablePlans()[2];
      
      // Annual plan (999/year) should be approximately 83/month
      expect(annualPlan.pricePerMonth.contains('82') || 
             annualPlan.pricePerMonth.contains('83'), true);
    });

    test('All plans include ad-free', () {
      final plans = SubscriptionPlan.getAvailablePlans();
      
      for (var plan in plans) {
        expect(plan.includesAdFree, true);
      }
    });

    test('Only Pro plans include Pro features', () {
      final plans = SubscriptionPlan.getAvailablePlans();
      
      expect(plans[0].includesProFeatures, false); // Ad-Free Basic
      expect(plans[1].includesProFeatures, true);  // Pro Monthly
      expect(plans[2].includesProFeatures, true);  // Pro Annual
    });
  });

  group('SubscriptionStatus Tests', () {
    test('All subscription statuses are defined', () {
      expect(SubscriptionStatus.free, isNotNull);
      expect(SubscriptionStatus.trial, isNotNull);
      expect(SubscriptionStatus.active, isNotNull);
      expect(SubscriptionStatus.expired, isNotNull);
      expect(SubscriptionStatus.cancelled, isNotNull);
    });
  });
}
