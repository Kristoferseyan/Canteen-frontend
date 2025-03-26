class ItemByCategory {
  final String id;
  final String itemName;
  final String description;
  final double price;
  final String categoryId;
  final int stock;
  final DateTime? featuredStartTime;
  final DateTime? featuredEndTime;

  ItemByCategory({
    required this.id,
    required this.itemName,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.stock,
    this.featuredStartTime,
    this.featuredEndTime,
  });

  bool get isFeatured {
    if (featuredStartTime == null || featuredEndTime == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(featuredStartTime!) && now.isBefore(featuredEndTime!);
  }
  
  String get featuredTimeRemaining {
    if (!isFeatured) return "";
    
    final now = DateTime.now();
    final difference = featuredEndTime!.difference(now);
    
    if (difference.inDays > 0) {
      return "${difference.inDays}d ${difference.inHours % 24}h remaining";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ${difference.inMinutes % 60}m remaining";
    } else {
      return "${difference.inMinutes}m remaining";
    }
  }

  factory ItemByCategory.fromJson(Map<String, dynamic> json) {
    return ItemByCategory(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] is String 
          ? double.parse(json['price']) 
          : (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId'] ?? '',
      stock: json['stock'] ?? 0,
      featuredStartTime: json['featuredStartTime'] != null 
          ? DateTime.parse(json['featuredStartTime']) 
          : null,
      featuredEndTime: json['featuredEndTime'] != null 
          ? DateTime.parse(json['featuredEndTime']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'stock': stock,
      'featuredStartTime': featuredStartTime?.toIso8601String(),
      'featuredEndTime': featuredEndTime?.toIso8601String(),
    };
  }
}