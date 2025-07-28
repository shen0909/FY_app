// 我的订阅-事件模型
class OrderEventModels {
  final String uuid;
  final String name;
  final String description;
  final List<String> keyword;
  final String createdAt;
  final String updatedAt;
  final int relateNewsCount;
  final int readingCount;
  final int followerCount;
  bool isFollowed; // 新增字段，表示是否已关注
  bool isEvent; // 新增字段，表示是否已关注

  OrderEventModels({
    required this.uuid,
    required this.name,
    required this.description,
    required this.keyword,
    required this.createdAt,
    required this.updatedAt,
    required this.relateNewsCount,
    required this.readingCount,
    required this.followerCount,
    this.isFollowed = false, // 初始值为false
    this.isEvent = false, // 初始值为false
  });

  factory OrderEventModels.fromJson(Map<String, dynamic> json) {
    final String keywordString = json['keyword'] as String;
    final List<String> keywordList = keywordString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return OrderEventModels(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      keyword: keywordList,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      relateNewsCount: json['relate_news_count'] as int,
      readingCount: json['reading_count'] as int,
      followerCount: json['follower_count'] as int,
      isFollowed: false, // 不从JSON中获取，初始化为false
      isEvent: false, // 不从JSON中获取，初始化为false
    );
  }

  // Optional: If you need to convert your Event object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'keyword': keyword.join(','),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'relate_news_count': relateNewsCount,
      'reading_count': readingCount,
      'follower_count': followerCount,
      'is_followed': isFollowed,
    };
  }

  @override
  String toString() {
    return 'Event(uuid: $uuid, name: $name, description: $description, keyword: $keyword, '
        'createdAt: $createdAt, updatedAt: $updatedAt, relateNewsCount: $relateNewsCount, '
        'readingCount: $readingCount, followerCount: $followerCount, isFollowed: $isFollowed)';
  }
}