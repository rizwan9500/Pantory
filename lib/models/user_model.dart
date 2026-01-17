class UserModel {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final bool isTrialActive;
  final DateTime? trialEndDate;
  final SubscriptionStatus subscriptionStatus;
  final String? currentPlan;
  
  // User preferences for personalized AI suggestions
  final String? country;
  final String? preferredCuisine;
  final List<String>? dietaryRestrictions; // e.g., ['vegetarian', 'vegan', 'halal', 'kosher']
  final List<String>? allergies; // e.g., ['peanuts', 'dairy', 'gluten', 'shellfish']
  final List<String>? dislikedFoods; // Foods user doesn't like

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.isTrialActive = false,
    this.trialEndDate,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.currentPlan,
    this.country,
    this.preferredCuisine,
    this.dietaryRestrictions,
    this.allergies,
    this.dislikedFoods,
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
      'country': country,
      'preferredCuisine': preferredCuisine,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
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
      country: json['country'],
      preferredCuisine: json['preferredCuisine'],
      dietaryRestrictions: json['dietaryRestrictions'] != null 
          ? List<String>.from(json['dietaryRestrictions']) 
          : null,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null,
      dislikedFoods: json['dislikedFoods'] != null 
          ? List<String>.from(json['dislikedFoods']) 
          : null,
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
    String? country,
    String? preferredCuisine,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? dislikedFoods,
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
      country: country ?? this.country,
      preferredCuisine: preferredCuisine ?? this.preferredCuisine,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
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
