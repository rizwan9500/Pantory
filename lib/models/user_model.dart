class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final bool isTrialActive;
  final DateTime? trialEndDate;
  final SubscriptionStatus subscriptionStatus;
  final String? currentPlan;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.isTrialActive = false,
    this.trialEndDate,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.currentPlan,
  });

  bool get hasActiveSubscription =>
      subscriptionStatus == SubscriptionStatus.active ||
      subscriptionStatus == SubscriptionStatus.trial;

  bool get isPro => subscriptionStatus == SubscriptionStatus.active;

  int get trialDaysRemaining {
    if (trialEndDate == null || !isTrialActive) return 0;
    final difference = trialEndDate!.difference(DateTime.now());
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isTrialActive': isTrialActive,
      'trialEndDate': trialEndDate?.toIso8601String(),
      'subscriptionStatus': subscriptionStatus.toString(),
      'currentPlan': currentPlan,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      isTrialActive: json['isTrialActive'] ?? false,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == json['subscriptionStatus'],
        orElse: () => SubscriptionStatus.free,
      ),
      currentPlan: json['currentPlan'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    bool? isTrialActive,
    DateTime? trialEndDate,
    SubscriptionStatus? subscriptionStatus,
    String? currentPlan,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      currentPlan: currentPlan ?? this.currentPlan,
    );
  }
}

enum SubscriptionStatus {
  free,
  trial,
  active,
  expired,
  cancelled,
}
