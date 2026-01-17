class ShoppingListItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final bool isChecked;
  final DateTime addedDate;
  final String? notes;
  final bool autoAdded; // Whether this was auto-added by the smart feature
  final bool isCompleted; // Whether item has been purchased
  final String? priority; // Priority: High, Medium, Low
  final double? estimatedPrice; // Estimated price for AI features

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.isChecked = false,
    required this.addedDate,
    this.notes,
    this.autoAdded = false,
    this.isCompleted = false,
    this.priority,
    this.estimatedPrice,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
      'autoAdded': autoAdded,
      'isCompleted': isCompleted,
      'priority': priority,
      'estimatedPrice': estimatedPrice,
    };
  }

  // Create from JSON
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
      addedDate: DateTime.parse(json['addedDate'] as String),
      notes: json['notes'] as String?,
      autoAdded: json['autoAdded'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: json['priority'] as String?,
      estimatedPrice: json['estimatedPrice'] as double?,
    );
  }

  // Copy with method
  ShoppingListItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    bool? isChecked,
    DateTime? addedDate,
    String? notes,
    bool? autoAdded,
    bool? isCompleted,
    String? priority,
    double? estimatedPrice,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
      autoAdded: autoAdded ?? this.autoAdded,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    );
  }
}
