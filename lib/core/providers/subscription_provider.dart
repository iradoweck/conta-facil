import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing the available subscription plans in Conta Fácil
enum SubscriptionPlan { free, pro }

/// Notifier to manage the user's active subscription plan
class SubscriptionNotifier extends StateNotifier<SubscriptionPlan> {
  SubscriptionNotifier() : super(SubscriptionPlan.free);

  /// Upgrade the user's account to the Pro tier (Premium Features)
  void upgradeToPro() {
    state = SubscriptionPlan.pro;
  }

  /// Downgrade the user's account to the Free tier (Basic Features)
  void downgradeToFree() {
    state = SubscriptionPlan.free;
  }

  /// Helper getter to quickly check if the active plan is Pro
  bool get isPro => state == SubscriptionPlan.pro;
}

/// Global provider to access the current Subscription Plan and toggle it
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionPlan>((ref) {
  return SubscriptionNotifier();
});
