class PantryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime addedDate;
  final String? notes;
  final bool isFavorite;

  PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.addedDate,
    this.notes,
    this.isFavorite = false,
  });

  // Calculate days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    return difference.inDays;
  }

  // Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if item is expiring soon (within 7 days)
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    if (days == null) return false;
    return days <= 7 && days > 0;
  }

  // Get expiry status text
  String get expiryStatus {
    if (expiryDate == null) return 'No expiry date';
    if (isExpired) return 'Expired';
    final days = daysUntilExpiry!;
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    if (days <= 7) return 'Expires in $days days';
    return 'Good condition';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  // Create from JSON
  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      addedDate: DateTime.parse(json['addedDate'] as String),
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  // Copy with method for updates
  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? addedDate,
    String? notes,
    bool? isFavorite,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
