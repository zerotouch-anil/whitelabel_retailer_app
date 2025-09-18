class Categories {
  final String id;
  final String categoryName;
  final String categoryId;
  final List<PercentItem> percentList;
  final bool isActive;
  final String img;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final Video? video;  // Added video

  Categories({
    required this.id,
    required this.categoryName,
    required this.categoryId,
    required this.percentList,
    required this.isActive,
    required this.img,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.video,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['_id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      percentList: (json['percentList'] as List<dynamic>?)
              ?.map((e) => PercentItem.fromJson(e))
              .toList() ??
          [],
      isActive: json['isActive'] ?? false,
      img: json['img'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime(2000),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime(2000),
      v: json['__v'] ?? 0,
      video: json['video'] != null
          ? Video.fromJson(json['video'] as Map<String, dynamic>)
          : null,
    );
  }

   Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'percentList': percentList.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'img': img,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'video': video?.toJson(),
    };
  }
}

class PercentItem {
  final String id;
  final double percent;
  final int duration;
  final bool isActive;

  PercentItem({
    required this.id,
    required this.percent,
    required this.duration,
    required this.isActive,
  });

  factory PercentItem.fromJson(Map<String, dynamic> json) {
    return PercentItem(
      id: json['_id'] ?? '',
      percent: (json['percent'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'percent': percent,
      'duration': duration,
      'isActive': isActive,
    };
  }
}

class Video {
  final String front;
  final String back;
  final String left;
  final String right;

  Video({
    required this.front,
    required this.back,
    required this.left,
    required this.right,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      left: json['left'] ?? '',
      right: json['right'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'front': front,
      'back': back,
      'left': left,
      'right': right,
    };
  }
}
