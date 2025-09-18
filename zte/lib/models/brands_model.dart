class Brand {
  final String id;
  final String brandName;
  final String brandId;
  final List<Category> categoryIds;
  final bool isActive;
  final String img;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Brand({
    required this.id,
    required this.brandName,
    required this.brandId,
    required this.categoryIds,
    required this.isActive,
    required this.img,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'],
      brandName: json['brandName'],
      brandId: json['brandId'],
      categoryIds: (json['categoryIds'] as List<dynamic>)
          .map((e) => Category.fromJson(e))
          .toList(),
      isActive: json['isActive'],
      img: json['img'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'brandName': brandName,
      'brandId': brandId,
      'categoryIds': categoryIds.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'img': img,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Category {
  final String categoryId;
  final String categoryName;
  final String id;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      '_id': id,
    };
  }
}
